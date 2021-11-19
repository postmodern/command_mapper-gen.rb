module CommandMapper
  module Gen
    module Types
      class Enum

        # @return [Array<Symbol>]
        attr_reader :values

        #
        # Initializes the enum type.
        #
        # @param [Array<Symbol>] values
        #
        def initialize(values)
          @values = values
        end

        #
        # Converts the map type to Ruby source code.
        #
        # @return [String]
        #
        def to_ruby
          "Enum[#{@values.map(&:inspect).join(', ')}]"
        end

      end
    end
  end
end
