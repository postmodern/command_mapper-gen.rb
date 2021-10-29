module CommandMapper
  module Gen
    module Types
      class KeyValue

        # @return [String]
        attr_reader :separator

        #
        # Initializes the key-value type.
        #
        # @param [String] separator
        #   The separator character.
        #
        def initialize(separator: '=')
          @separator = separator
        end

        #
        # Converts the key-value type to Ruby source code.
        #
        # @return [String]
        #
        def to_ruby
          ruby = "KeyValue.new("
          ruby << "separator: #{@separator.inspect}" unless @separator == '='
          ruby << ")"
          ruby
        end

      end
    end
  end
end
