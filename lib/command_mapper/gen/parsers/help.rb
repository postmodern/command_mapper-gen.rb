require 'command_mapper/gen/parsers/options'
require 'command_mapper/gen/parsers/usage'
require 'command_mapper/gen/command'

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

        #
        # Prints a parser error.
        #
        # @param [String] line
        #   The line that could not be parsed.
        #
        # @param [Parslet::ParseFailed] error
        #   The parsing error.
        #
        def print_parser_error(line,error)
          warn "failed to parse line:"
          warn ""
          warn "  #{line}"

          error.parse_failure_cause.ascii_tree.each_line do |backtrace_line|
            warn "  #{backtrace_line}"
          end
          warn ""
        end

        #
        # Parses a `usage: ...` string into {#command}.
        #
        # @param [String] usage
        #
        def parse_usage(usage)
          parser = Usage.new

          nodes = begin
                    parser.parse(usage)
                   rescue Parslet::ParseFailed => error
                     print_parser_error(usage,error)
                     return
                   end

          nodes.each do |node|
            if (command_name = node[:command_name])
              # optionally set the program name, if it already hasn't been given
              @command.command_name ||= command_name
            else
              if node[:optional]
                argument = node[:optional][:argument]
                keywords = {required: false}
              else
                argument = node[:argument]
                keywords = {}
              end

              if argument
                if node[:repeats] || argument[:repeats]
                  keywords[:repeats] = true
                end

                name = argument[:name].to_s.downcase.to_sym

                # ignore [OPTIONS] or [opts]
                unless (name == :option || name == :options || name == :opts)
                  @command.argument(name,**keywords)
                end
              end
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
          parser = Parsers::Options.new
          tree   = begin
                     parser.parse(line)
                   rescue Parslet::ParseFailed => error
                     print_parser_error(line,error)
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
