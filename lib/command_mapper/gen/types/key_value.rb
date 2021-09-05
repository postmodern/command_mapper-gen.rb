module CommandMapper
  module Gen
    module Types
      class KeyValue

        #
        # Initializes the key-value type.
        #
        # @param [String] separator
        #   The separator character.
        #
        def initialize(separator)
          @separator = separator
        end

        #
        # Converts the map type to Ruby source code.
        #
        # @return [String]
        #
        def to_ruby
          "KeyValue.new(#{separator.inspect})"
        end

      end
    end
  end
end
