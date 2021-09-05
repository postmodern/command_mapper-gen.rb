require 'command_mapper/gen/command'

require 'strscan'

module CommandMapper
  module Gen
    module Parsers
      class Help

        # @return [CommandMapper::Gen::Command]
        attr_reader :command

        #
        # Initializes the `--help` output parser.
        #
        def initialize(command)
          @command = command
        end

        #
        # Parses the `--help` output for the given command.
        #
        # @param [Command] command
        #   The command object to parse data into.
        #
        # @param [String] output
        #   The `--help` output to parse.
        #
        # @return [Command]
        #   The parsed command.
        #
        def self.parse(command,output)
          parser = new(command)
          parser.parse(output)

          return command
        end

        #
        # Runs the parser on the command's `--help` output.
        #
        # @param [Command] command
        #   The command object to parse data into.
        #
        # @return [Command, nil]
        #   Returns `nil` if the command could not be found.
        #
        def self.run(command)
          output = `#{command.command_name} --help`

          parse(command,output) unless output.empty?
        end

        ARGUMENT_NAME = /[a-z_]+|[A-Z_]+|\<[a-z]+[ a-z_-]*\>/

        DOT_DOT_DOT = /\.\.\./

        #
        # @param [String] usage
        #
        # @param [Command] command
        #
        def parse_usage(usage)
          scanner = StringScanner.new(usage)

          # skip the program name
          @command.command_name ||= scanner.scan(/\w+/)

          until scanner.eos?
            # skip whitespace
            scanner.skip(/\s+/)

            # skip any options
            scanner.skip(/-[a-zA-Z0-9_-]+\s+/)

            argument = nil
            keywords = {}

            # detect optional openning [ or {
            if scanner.skip(/[\[\{]/)
              keywords[:required] = false
            end

            # skip optional space after [ or {
            scanner.skip(/\s+/)

            argument = scanner.scan(ARGUMENT_NAME)

            if scanner.skip(/\s*#{DOT_DOT_DOT}/)
              keywords[:repeats] = true
              scanner.skip(/\s+/)
            elsif scanner.skip(/,#{DOT_DOT_DOT}/)
              keywords[:repeats] = true
              keywords[:type]    = Types::List.new(',')
            end

            if keywords[:required] == false
              # skip the closing ] or }
              scanner.skip(/[\]\}]/)
            end

            if scanner.skip(/\s*#{DOT_DOT_DOT}/)
              keywords[:repeats] = true
            end

            if argument
              name = argument.downcase.to_sym

              # ignore [OPTIONS] or [opts]
              unless (name == :option || name == :options || name == :opts)
                @command.arguments[name] = Argument.new(name,**keywords)
              end
            else
              warn "could not scan argument name at: #{scanner.rest}"
            end
          end
        end

        def parse_option_value(arg)
          scanner  = StringScanner.new(arg)
          value    = {}
          keywords = {value: value}

          # skip any opening [
          if scanner.skip(/\[/)
            value[:required] = false
          end

          # skip the = character
          if scanner.skip(/=/)
            keywords[:equals] = true
          end

          name = scanner.scan(ARGUMENT_NAME)

          if scanner.skip(/,#{DOT_DOT_DOT}/)
            # ,... detected
            value[:type] = Types::List.new(',')
          elsif scanner.skip(/=#{ARGUMENT_NAME}/)
            # NAME=VALUE detected
            value[:type] = Types::KeyValue.new('=')
          elsif scanner.skip(/:#{ARGUMENT_NAME}/)
            # NAME:VALUE detected
            value[:type] = Types::KeyValue.new(':')
          elsif scanner.skip(/\|/)
            # foo|bar detected
            next_name = scanner.scan(ARGUMENT_NAME)

            case name
            when 'yes', 'y'
              if next_name == 'no' || next_name == 'n'
                # yes|no detected
                value[:type] = Types::Map.new(true => name, false => next_name)
              end
            when 'enabled'
               if next_name == 'disabled'
                # enabled|disabled detected
               value[:type] = Types::Map.new(true => name, false => next_name)
              end
            else
              # foo|bar|... detected
              map = {name.to_sym => name, next_name.to_sym => next_name}

              # consume the rest of the |... choises
              while scanner.skip(/\|/)
                next_name = scanner.scan(ARGUMENT_NAME)

                if name =~ /[a-z0-9_-]+/
                  map[next_name.to_sym] = next_name
                end
              end

              value[:type] = Types::Map.new(map)
            end
          end

          if value[:required] == false
            # skip the closing ]
            scanner.skip(/\]/)
          end

          return keywords
        end

        #
        # @param [String] usage
        #
        # @param [Command] command
        #
        def parse_option(line)
          scanner = StringScanner.new(line)

          flag     = nil
          keywords = {}

          # skip whitespace
          scanner.skip(/\s+/)

          # attempt to scan the short option
          if (short_flag = scanner.scan(/-[a-zA-Z0-9][a-zA-Z0-9_-]*/))
            # is there a space after the short option?
            if scanner.skip(/\s/)
              # is there an argument name?
              if (arg = scanner.scan(/\S+/))
                # parse the argument name following the short option
                keywords.merge!(parse_option_value(arg))
              end
            end

            # skip there a ','?
            scanner.skip(/,\s+/)
          end

          # scan the long option
          if (long_flag = scanner.scan(/--[a-zA-Z][a-zA-Z0-9_-]+/))
            # attempt to skip the '='
            if scanner.skip(/=/)
              keywords[:equals] = true

              # scan the option's ARG
              if (arg = scanner.scan(/\S+/))
                # scan the option's ARG
                keywords.merge!(parse_option_value(arg))
              end
            else
              # no '=' character? skip the whitespace character
              if scanner.skip(/\s/)
                if (arg = scanner.scan(/\S+/))
                  # scan the option's ARG
                  keywords.merge!(parse_option_value(arg))
                end
              end
            end
          end

          if (flag = long_flag || short_flag)
            @command.options[flag] = Option.new(flag,**keywords)
          else
            warn "could not detect option flag: #{line}"
          end
        end

        USAGE = /^usage:\s/i

        OPTION_LINE = /^\s+-/

        #
        # @param [String] output
        #
        # @param [Command] command
        #
        def parse(output)
          output.each_line do |line|
            if line =~ USAGE
              parse_usage(line.sub(USAGE,'').chomp)
            elsif line =~ OPTION_LINE
              parse_option(line.chomp)
            end
          end
        end

      end
    end
  end
end
