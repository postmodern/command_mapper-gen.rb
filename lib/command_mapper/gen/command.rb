require 'command_mapper/gen/option'
require 'command_mapper/gen/argument'
require 'command_mapper/gen/types'

module CommandMapper
  module Gen
    #
    # Represents a mock `CommandMapper::Command` class that will be populated
    # by the {Parsers} and written out to a file.
    #
    # @api private
    #
    class Command

      # The command's name.
      #
      # @return [String, nil]
      attr_accessor :command_name

      # The parent command of this sub-command.
      #
      # @return [Command, nil]
      attr_reader :parent_command

      # @return [Hash{String => Option}]
      attr_reader :options

      # @return [Hash{Symbol => Argument}]
      attr_reader :arguments

      # @return [Hash{String => Command}]
      attr_reader :subcommands

      #
      # Initializes the parsed command.
      #
      # @param [String, nil] command_name
      #   The command name or path to the command.
      #
      def initialize(command_name=nil,parent_command=nil)
        @command_name   = command_name
        @parent_command = parent_command

        @options     = {}
        @arguments   = {}
        @subcommands = {}
      end

      #
      # The command string to run the command.
      #
      # @return [String]
      #
      def command_string
        if @parent_command
          "#{@parent_command.command_string} #{@command_name}"
        else
          @command_name
        end
      end

      #
      # The man-page name for the command.
      #
      # @return [String]
      #
      def man_page
        if @parent_command
          "#{@parent_command.man_page}-#{@command_name}"
        else
          @command_name
        end
      end

      #
      # Defines an option for the command.
      #
      # @param [String] flag
      #
      # @param [Hash{Symbol => Object}] kwargs
      #
      def option(flag,**kwargs)
        @options[flag] = Option.new(flag,**kwargs)
      end

      #
      # Defines an argument for the command.
      #
      # @param [Symbol] name
      #
      # @param [Hash{Symbol => Object}] kwargs
      #
      def argument(name,**kwargs)
        @arguments[name] = Argument.new(name,**kwargs)
      end

      #
      # Defines a new sub-command.
      #
      # @param [String] name
      #   The subcommand name.
      #
      # @return [Command]
      #   The newly defined subcommand.
      #
      def subcommand(name)
        @subcommands[name] = Command.new(name,self)
      end

      #
      # The CamelCase class name derived from the {#command_name}.
      #
      # @return [String, nil]
      #   The class name or `nil` if {#command_name} is also `nil`.
      #
      def class_name
        if @command_name
          @command_name.split(/[_-]+/).map(&:capitalize).join
        end
      end

      #
      # Converts the parsed command to Ruby source code.
      #
      # @return [String]
      #   The generated ruby source code for the command.
      #
      def to_ruby
        lines = []

        if @parent_command.nil?
          if @command_name
            lines << "require 'command_mapper/command'"
            lines << ""
            lines << "#"
            lines << "# Represents the `#{@command_name}` command"
            lines << "#"

            lines << "class #{class_name} < CommandMapper::Command"
            lines << ""
            lines << "  command #{@command_name.inspect} do"
          end

          indent = "    "
        else
          lines << "subcommand #{@command_name.inspect} do"

          indent = "  "
        end

        unless @options.empty?
          @options.each_value do |option|
            lines << "#{indent}#{option.to_ruby}"
          end
        end

        if (!@options.empty? && !@arguments.empty?)
          lines << ''
        end

        unless @arguments.empty?
          @arguments.each_value do |argument|
            lines << "#{indent}#{argument.to_ruby}"
          end
        end

        unless @subcommands.empty?
          if (!@options.empty? || !@arguments.empty?)
            lines << ''
          end

          @subcommands.each_value.each_with_index do |subcommand,index|
            lines << '' if index > 0

            subcommand.to_ruby.each_line do |line|
              if line == $/
                lines << ''
              else
                lines << "#{indent}#{line.chomp}"
              end
            end
          end
        end

        if @parent_command.nil?
          if @command_name
            lines << "  end"
            lines << ''
          end
        end

        lines << "end"

        return lines.join($/) + $/
      end

      #
      # Saves the parsed command to the given file path.
      #
      # @param [String] path
      #
      def save(path)
        File.write(path,to_ruby)
      end

    end
  end
end
