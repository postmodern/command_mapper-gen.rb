require 'rake/tasklib'

module CommandMapper
  module Gen
    class Task < Rake::TaskLib

      # The command name or path to the command.
      #
      # @return [String]
      attr_reader :command_name

      # The output file path.
      #
      # @return [String]
      attr_reader :output

      # The parser to invoke.
      #
      # @return [:help, :man, nil]
      attr_reader :parser

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
      def initialize(command_name,output, parser: nil)
        @command_name = command_name
        @output       = output

        @parser = parser

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
