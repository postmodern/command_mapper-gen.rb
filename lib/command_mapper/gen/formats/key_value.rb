module CommandMapper
  module Gen
    module Formats
      class KeyValue

        #
        # Initializes the key-value format.
        #
        # @param [String] separator
        #   The separator character.
        #
        def initialize(separator)
          @separator = separator
        end

        #
        # Converts the map format to Ruby source code.
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
