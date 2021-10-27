require 'command_mapper/gen/option'
require 'command_mapper/gen/argument'

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

      # @return [Hash{String => Option}]
      attr_reader :options

      # @return [Hash{Symbol => Argument}]
      attr_reader :arguments

      #
      # Initializes the parsed command.
      #
      # @param [String, nil] command_name
      #   The command name or path to the command.
      #
      def initialize(command_name=nil)
        @command_name = command_name

        @options   = {}
        @arguments = {}
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

        unless options.empty?
          options.each_value do |option|
            lines << "    #{option.to_ruby}"
          end
        end

        if (!options.empty? && !arguments.empty?)
          lines << ''
        end

        unless arguments.empty?
          arguments.each_value do |argument|
            lines << "    #{argument.to_ruby}"
          end
        end

        if @command_name
          lines << "  end"
          lines << ''
          lines << "end"
        end

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
