require 'command_mapper/gen/types/value'

module CommandMapper
  module Gen
    #
    # Represents a mock `CommandMapper::Argument` class.
    #
    class Argument

      # The name of the argument.
      #
      # @return [Symbol]
      attr_reader :name

      # The value configuration for the argument.
      #
      # @return [Value, nil]
      attr_reader :value

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
      def initialize(name, repeats: nil, value: nil)
        @name    = name
        @value   = case value
                   when Types::Value then value
                   when Hash         then Types::Value.new(**value)
                   when nil          then nil
                   end
        @repeats = repeats
      end

      #
      # Converts the parsed argument to Ruby source code.
      #
      # @return [String]
      #
      def to_ruby
        ruby = "argument #{@name.inspect}"
        ruby << ", value: #{@value.to_ruby}" if @value
        ruby << ", repeats: #{@repeats.inspect}" unless @repeats.nil?
        ruby
      end

    end
  end
end
