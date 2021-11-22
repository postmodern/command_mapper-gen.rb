require 'rake/tasklib'

module CommandMapper
  module Gen
    class Task < Rake::TaskLib

      # The command name or path to the command.
      #
      # @return [String]
      attr_accessor :command_name

      # The output file path.
      #
      # @return [String]
      attr_accessor :output

      # The parser to invoke.
      #
      # @return [:help, :man, nil]
      attr_accessor :parser

      #
      # Initializes the task.
      #
      # @param [String] command_name
      #   The command name or path to the command.
      #
      # @param [String] output
      #   The output file path.
      #
      # @param [:help, :man, nil] parser
      #   The optional parser to target.
      #
      # @yield [task]
      #   If a block is given, it will be yielded to before the rake task has
      #   been defined.
      #
      # @yieldparam [Task] task
      #   The newly created task.
      #
      def initialize(command_name,output, parser: nil)
        @command_name = command_name
        @output       = output

        @parser = parser

        yield self if block_given?
        define
      end

      #
      # Defines the `command_mapper:gen` task and output file's task.
      #
      def define
        output_dir = File.dirname(@output)

        directory(output_dir)
        file(@output => output_dir) do
          args = ["--output", @output]

          if @parser
            args << '--parser' << @parser.to_s
          end

          sh "command_mapper-gen", *args, @command_name
        end

        desc "Generates the #{@output} file"
        task 'command_mapper:gen' => @output
      end

    end
  end
end
