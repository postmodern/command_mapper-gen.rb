require 'command_mapper/gen/arg'

module CommandMapper
  module Gen
    #
    # Represents a mock `CommandMapper::Argument` class.
    #
    class Argument < Arg

      # The name of the argument.
      #
      # @return [Symbol]
      attr_reader :name

      #
      # Initializes the parsed argument.
      #
      # @param [Symbol] name
      #   The argument name.
      #
      # @param [Boolean, nil] repeats
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments.
      #
      def initialize(name, **kwargs)
        super(**kwargs)

        @name = name
      end

      #
      # Converts the parsed argument to Ruby source code.
      #
      # @return [String]
      #
      def to_ruby
        keywords = super()

        ruby = "argument #{@name.inspect}"
        ruby << ", #{keywords}" unless keywords.empty?
        ruby
      end

    end
  end
end
