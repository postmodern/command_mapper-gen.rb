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

      # @return [Boolean, nil]
      attr_reader :repeats

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
      def initialize(name, repeats: nil, **kwargs)
        super(**kwargs)

        @name    = name
        @repeats = repeats
      end

      #
      # Converts the parsed argument to Ruby source code.
      #
      # @return [String]
      #
      def to_ruby
        ruby = "argument #{@name.inspect}"

        keywords = super()
        ruby << ", #{keywords}" unless keywords.empty?

        ruby << ", repeats: #{@repeats.inspect}" unless @repeats.nil?
        ruby
      end

    end
  end
end
