require 'command_mapper/gen/argument_value'

module CommandMapper
  module Gen
    #
    # Represents a mock `CommandMapper::Argument` class.
    #
    class Argument < ArgumentValue

      # The name of the argument.
      #
      # @return [Symbol]
      attr_reader :name

      # @return [Boolean, nil]
      attr_reader :repeats

      #
      # Initializes the parsed argument.
      #
      # @param [String] name
      #   The argument name.
      #
      # @param [Boolean, nil] repeats
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments.
      #
      def initialize(name, repeats: nil, **kwargs)
        @name    = name
        @repeats = repeats

        super(**kwargs)
      end

      #
      # Converts the parsed argument to Ruby source code.
      #
      # @return [String]
      #
      def to_ruby
        ruby = "argument #{@name.inspect}"
        ruby << ", repeats: #{@repeats}" unless @repeats.nil?

        unless (keywords = super()).empty?
          ruby << ", #{keywords}"
        end

        ruby
      end

    end
  end
end
