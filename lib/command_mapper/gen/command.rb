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

      # The command name or path to the command.
      #
      # @return [String, nil]
      attr_reader :command

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
      # @param [String] command
      #   The command name or path to the command.
      #
      def initialize(command=nil)
        @command = command

        @command_name = if command
                          File.basename(command)
                        end

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
      # Converts the parsed command to Ruby source code.
      #
      # @return [String]
      #   The generated ruby source code for the command.
      #
      def to_ruby
        lines = []

        if @command_name
          lines << "#"
          lines << "# Represents the `#{@command_name}` command"
          lines << "#"

          lines << "class #{@command_name.capitalize} < CommandMapper::Command"
          lines << ""
          lines << "  command #{@command_name.inspect}"
          lines << ""
        end

        unless options.empty?
          options.each_value do |option|
            lines << "  #{option.to_ruby}"
          end
        end

        if (!options.empty? && !arguments.empty?)
          lines << ''
        end

        unless arguments.empty?
          arguments.each_value do |argument|
            lines << "  #{argument.to_ruby}"
          end
        end

        if @command_name
          lines << ''
          lines << "end"
        end

        return lines.join($/)
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
