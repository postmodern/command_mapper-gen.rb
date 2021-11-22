require 'command_mapper/gen/parsers/options'
require 'command_mapper/gen/parsers/usage'
require 'command_mapper/gen/command'
require 'command_mapper/gen/exceptions'

module CommandMapper
  module Gen
    module Parsers
      class Help

        # @return [Command]
        attr_reader :command

        # The callback to pass any parser errors.
        #
        # @return [Proc(String, Parslet::ParserFailed), nil]
        attr_reader :parser_error_callback

        #
        # Initializes the `--help` output parser.
        #
        # @param [Command] command
        #
        # @yield [line, parser_error]
        #   If a block is given, it will be used as a callback for any parser
        #   errors.
        #
        # @yieldparam [String] line
        #   The line that triggered the parser error.
        #
        # @yieldparam [Parslet::ParserFailed] parser_error
        #   The parser error.
        #
        def initialize(command,&block)
          @command = command

          @parser_error_callback = block
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
        def self.parse(output,command,&block)
          parser = new(command,&block)
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
        # @raise [CommandNotInstalled]
        #   The command could not be found on the system.
        #
        def self.run(command,&block)
          output = nil

          begin
            output = `#{command.command_string} --help 2>&1`
          rescue Errno::ENOENT
            # command not found
            raise(CommandNotInstalled,"command #{command.command_name.inspect} is not installed")
          end

          if output.empty?
            # --help not supported, fallback to trying -h
            output = `#{command.command_string} -h 2>&1`
          end

          parse(output,command,&block) unless output.empty?
        end

        # List of argument names to ignore
        IGNORED_ARGUMENT_NAMES = %w[option options opts]

        #
        # Determines whether to skip an argument based on it's name.
        #
        # @param [String] name
        #   The argument name.
        #
        # @return [Boolean]
        #   Indicates whether to skip the argument or not.
        #
        def ignore_argument?(name)
          name == @command.command_name || 
            IGNORED_ARGUMENT_NAMES.any? { |suffix|
              name == suffix || name.end_with?(suffix)
            }
        end

        #
        # Parses an individual argument node.
        #
        # @param [Hash] node
        #   An argument node.
        #
        def parse_argument(argument,**kwargs)
          name     = argument[:name].to_s.downcase
          keywords = kwargs

          if argument[:repeats]
            keywords[:repeats] = true
          end

          # ignore [OPTIONS] or [opts]
          unless ignore_argument?(name)
            @command.argument(name.to_sym,**keywords)
          end
        end

        #
        # Parses a node within the arguments node.
        #
        # @param [Hash] node
        #
        def parse_argument_node(node,**kwargs)
          keywords = kwargs

          if node[:repeats]
            keywords[:repeats] = true
          end

          if node[:optional]
            keywords[:required] = false

            parse_arguments(node[:optional], **keywords)
          else
            parse_argument(node[:argument], **keywords)
          end
        end

        #
        # Parses a collection of arguments.
        #
        # @param [Array<Hash>, Hash] arguments
        #
        def parse_arguments(arguments,**kwargs)
          case arguments
          when Array
            keywords = kwargs

            if arguments.delete({repeats: '...'})
              keywords[:repeats] = true
            end

            arguments.each do |node|
              parse_argument_node(node,**keywords)
            end
          when Hash
            parse_argument_node(arguments,**kwargs)
          end
        end

        #
        # Parses a `usage: ...` string into {#command}.
        #
        # @param [String] usage
        #
        def parse_usage(usage)
          parser = Usage.new

          # remove the command name and any subcommands
          args = usage.sub("#{@command.command_string} ",'')

          tree = begin
                   parser.args.parse(args)
                 rescue Parslet::ParseFailed => error
                   if @parser_error_callback
                     @parser_error_callback.call(usage,error)
                   end

                   return
                 end

          parse_arguments(tree)
        end

        #
        # Parses an option line (ex: `    -o, --opt VALUE      Blah blah blah`)
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
                     if @parser_error_callback
                       @parser_error_callback.call(line,error)
                     end

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

            value_node = tree[:optional][:value]
            keywords[:value] = {required: false}
          elsif tree[:value]
            value_node = tree[:value]
            keywords[:value] = {required: true}
          end

          if value_node
            if value_node[:list]
              separator = value_node[:list][:separator]

              keywords[:value][:type] = Types::List.new(
                separator: separator.to_s
              )
            elsif value_node[:key_value]
              separator = value_node[:key_value][:separator]

              keywords[:value][:type] = Types::KeyValue.new(
                separator: separator.to_s
              )
            elsif value_node[:literal_values]
              literal_values = []

              value_node[:literal_values].each do |node|
                literal_values << node[:string].to_s
              end

              # perform some value coercion
              type = case literal_values
                     when %w[YES NO]
                       Types::Map.new(true => 'YES', false => 'NO')
                     when %w[Yes No]
                       Types::Map.new(true => 'Yes', false => 'No')
                     when %w[yes no]
                       Types::Map.new(true => 'yes', false => 'no')
                     when %w[Y N]
                       Types::Map.new(true => 'Y', false => 'N')
                     when %w[y n]
                       Types::Map.new(true => 'y', false => 'n')
                     when %w[ENABLED DISABLED]
                       Types::Map.new(true => 'ENABLED', false => 'DISABLED')
                     when %w[Enabled Disabled]
                       Types::Map.new(true => 'Enabled', false => 'Disabled')
                     when %w[enabled disabled]
                       Types::Map.new(true => 'enabled', false => 'disabled')
                     else
                       Types::Enum.new(literal_values.map(&:to_sym))
                     end

              keywords[:value][:type] = type
            elsif value_node[:name]
              case value_node[:name]
              when 'NUM'
                keywords[:value][:type] = Types::Num.new
              end
            end
          end

          if flag
            @command.option(flag.to_s, **keywords)
          else
            warn "could not detect option flag: #{line}"
          end
        end

        USAGE_PREFIX = /^usage:\s+/i

        USAGE_LINE = /#{USAGE_PREFIX}[a-z][a-z0-9_-]*/i

        USAGE_SECTION = /^usage:$/i

        INDENT = /^\s{2,}/

        OPTION_LINE = /#{INDENT}-(?:[A-Za-z0-9]|-[A-Za-z0-9])/

        SUBCOMMAND = /[a-z][a-z0-9]*(?:[_-][a-z0-9]+)*/

        SUBCOMMAND_LINE = /^\s{2,}(#{SUBCOMMAND})(?:,\s[a-z][a-z0-9_-]*)?(?:\t|\s{2,}|$)/

        def parse_subcommand_line(line)
          if (match = line.match(SUBCOMMAND))
            subcommand_name = match[0]

            # filter out self-referetial subcommands
            unless subcommand_name == @command.command_name
              @command.subcommand(subcommand_name)
            end
          end
        end

        #
        # Parses `--help` output into {#command}.
        #
        # @param [String] output
        #   The full `--help` output.
        #
        def parse(output)
          usage_on_next_line = false

          output.each_line do |line|
            if line =~ USAGE_SECTION
              usage_on_next_line = true
            elsif usage_on_next_line
              if line =~ INDENT
                parse_usage(line.strip)
              else
                usage_on_next_line = false
              end
            else
              if line =~ USAGE_LINE
                usage = line.sub(USAGE_PREFIX,'').chomp

                parse_usage(usage)
              elsif line =~ OPTION_LINE
                parse_option_line(line.chomp)
              elsif line =~ SUBCOMMAND_LINE
                parse_subcommand_line(line.chomp)
              end
            end
          end
        end

      end
    end
  end
end
