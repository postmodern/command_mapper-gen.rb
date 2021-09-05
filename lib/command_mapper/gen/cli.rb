require 'command_mapper/gen/parsers'
require 'command_mapper/gen/command'
require 'command_mapper/gen/version'

require 'optparse'

module CommandMapper
  module Gen
    class CLI

      PROGRAM_NAME = "command_mapper-gen"

      PARSERS = {
        'help' => Parsers::Help,
        'man'  => Parsers::Man
      }

      BUG_REPORT_URL = "https://github.com/postmodern/command_mapper-gen/issues/new"

      # The output file or `nil` for stdout.
      #
      # @return [File, nil]
      attr_reader :output

      # The parsers to run.
      #
      # @return [Array<Parsers::Help, Parsers::Man>]
      attr_reader :parsers

      # The parsed command.
      #
      # @return [Command]
      attr_reader :command

      # The command's option parser.
      #
      # @return [OptionParser]
      attr_reader :option_parser

      #
      # Initializes the command.
      #
      def initialize
        @output  = nil
        @parsers = PARSERS.values
        @command = nil

        @option_parser = option_parser
      end

      #
      # Initializes and runs the command.
      #
      # @param [Array<String>] argv
      #   Command-line arguments.
      #
      def self.run(argv=ARGV)
        new().run(argv)
      end

      #
      # Runs the command.
      #
      # @param [Array<String>] argv
      #   Command-line arguments.
      #
      def run(argv=ARGV)
        argv = @option_parser.parse(argv)

        if (command_name = argv.first)
          @command = Command.new(command_name)

          @parsers.each do |parser|
            begin
              parser.run(command)
            rescue => error
              print_backtrace(error)
              exit -1
            end
          end
        else
          @command = Command.new
          parser   = Parsers::Help.new(command)

          begin
            parser.parse($stdin.read)
          rescue => error
            print_backtrace(error)
            exit -1
          end
        end

        if (@command.options.empty? && @command.arguments.empty?)
          print_error "no options or arguments detected"
          exit -2
        end

        if @output then @command.save(@output)
        else            puts command.to_ruby
        end
      end

      #
      # The option parser.
      #
      # @return [OptionParser]
      #
      def option_parser
        OptionParser.new do |opts|
          opts.banner = "usage: #{PROGRAM_NAME} [options] [COMMAND_NAME]"

          opts.separator ""
          opts.separator "Options:"

          opts.on('-o','--output FILE','Saves the output to FILE') do |file|
            @output = file
          end

          opts.on('-p','--parser=PARSER', PARSERS, 'Selects which parser to use (help or man)') do |parser|
            @parsers = [parser]
          end

          opts.on('-V','--version','Print the version') do
            puts "command_mapper-gen #{VERSION}"
            exit
          end

          opts.on('-h','--help','Print the help output') do
            puts opts
            exit
          end

          opts.separator ""
          opts.separator "Examples:"
          opts.separator "    command_mapper-gen grep"
          opts.separator ""
        end
      end

      #
      # Prints an error message to stderr.
      #
      # @param [String] error
      #   The error message.
      #
      def print_error(error)
        $stderr.puts "#{PROGRAM_NAME}: #{error}"
      end

      #
      # Prints a backtrace to stderr.
      #
      # @param [Exception] exception
      #   The exception.
      #
      def print_backtrace(exception)
        $stderr.puts "Oops! Looks like you've found a bug!"
        $stderr.puts "Please report the following to: #{BUG_REPORT_URL}"
        $stderr.puts
        $stderr.puts "```"
        $stderr.puts "#{exception.full_message}"
        $stderr.puts "```"
      end

    end
  end
end
