require 'command_mapper/gen/parsers/option'
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
          output = begin
                     `#{command.command} --help 2>&1`
                   rescue Errno::ENOENT
                   end

          parse(command,output) unless (output.nil? || output.empty?)
        end

        COMMAND_NAME = /[a-zA-Z][a-zA-Z0-9_-]*/

        STRING_LITERAL = /[a-z0-9_-]+/

        ARGUMENT_NAME = /[a-z_]+|[A-Z_]+|\<[a-z]+[ a-z_-]*\>/

        DOT_DOT_DOT = /\.\.\./

        #
        # Parses a `usage: ...` string into {#command}.
        #
        # @param [String] usage
        #
        def parse_usage(usage)
          scanner = StringScanner.new(usage)

          # scan the program name
          command_name = scanner.scan(COMMAND_NAME)

          # optionally set the program name, if it already hasn't been given
          @command.command_name ||= command_name

          until scanner.eos?
            # skip whitespace
            scanner.skip(/\s+/)

            # skip any options
            scanner.skip(/-[a-zA-Z0-9_-]+\s+/)

            argument = nil
            keywords = {}

            # detect optional openning [ or {
            if scanner.skip(/[\[\{]\s*/)
              keywords[:required] = false
            end

            argument = scanner.scan(ARGUMENT_NAME)

            if scanner.skip(/\s*#{DOT_DOT_DOT}\s*/)
              keywords[:repeats] = true
            elsif scanner.skip(/,#{DOT_DOT_DOT}\s*/)
              keywords[:repeats] = true
              keywords[:type]    = Types::List.new(',')
            end

            if keywords[:required] == false
              # skip the closing ] or }
              scanner.skip(/[\]\}]\s*/)
            end

            if scanner.skip(/\s*#{DOT_DOT_DOT}\s*/)
              keywords[:repeats] = true
            end

            if argument
              name = argument.downcase.to_sym

              # ignore [OPTIONS] or [opts]
              unless (name == :option || name == :options || name == :opts)
                @command.argument(name,**keywords)
              end
            else
              warn "could not scan argument name at: #{scanner.rest}"
            end
          end
        end

        #
        # Parses an option line (ex: `    -o, --opt VALUE      Blah blah lbah`)
        # into {#command}.
        #
        # @param [String] line
        #   The option line to parse.
        #
        def parse_option_line(line)
          parser = Parsers::Option.new
          tree   = begin
                     parser.parse(line)
                   rescue Parslet::ParseFailed => error
                     warn "could not parse line: #{line}"
                     warn error.parse_failure_cause.ascii_tree
                     return
                   end

          flag = tree[:long_flag] || tree[:short_flag]
          keywords = {}

          if tree[:equals]
            keywords[:equals] = true
          end

          if tree[:optional]
            if tree[:optional][:equals]
              keywords[:equals] = :optional
            end

            value = tree[:optional][:value]

            keywords[:value] = {required: false}
          elsif tree[:value]
            value = tree[:value]

            keywords[:value] = {}
          end

          if value
            if value[:list]
              separator = value[:list][:separator]

              keywords[:value][:type] = Types::List.new(separator.to_s)
            elsif value[:key_value]
              separator = value[:key_value][:separator]

              keywords[:value][:type] = Types::KeyValue.new(separator.to_s)
            elsif value[:literal_values]
              map = {}

              value[:literal_values].each do |node|
                map[node[:string].to_sym] = node[:string].to_s
              end

              # perform some value coercion
              case map
              when {yes: 'yes', no: 'no'}
                map = {true => 'yes', false => 'no'}
              when {y: 'y', n: 'n'}
                map = {true => 'y', false => 'n'}
              when {enabled: 'enabled', disabled: 'disabled'}
                map = {true => 'enabled', false => 'disabled'}
              end

              keywords[:value][:type] = Types::Map.new(map)
            elsif value[:name]
              # NOTE: maybe use this in the future
            end
          end

          if flag
            @command.option(flag.to_s, **keywords)
          else
            warn "could not detect option flag: #{line}"
          end
        end

        USAGE = /^usage:\s/i

        OPTION_LINE = /^\s+-/

        #
        # Parses `--help` output into {#command}.
        #
        # @param [String] output
        #   The full `--help` output.
        #
        def parse(output)
          output.each_line do |line|
            if line =~ USAGE
              parse_usage(line.sub(USAGE,'').chomp)
            elsif line =~ OPTION_LINE
              parse_option_line(line.chomp)
            end
          end
        end

      end
    end
  end
end
