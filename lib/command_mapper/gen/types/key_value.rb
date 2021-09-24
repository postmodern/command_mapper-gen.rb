require 'command_mapper/gen/types/value'

module CommandMapper
  module Gen
    module Formats
      class KeyValue < Value

        #
        # Initializes the key-value type.
        #
        # @param [String] separator
        #   The separator character.
        #
        def initialize(separator: ',', **kwargs)
          super(**kwargs)

          @separator = separator
        end

        #
        # Converts the key-value type to Ruby source code.
        #
        # @return [String]
        #
        def to_ruby
          ruby = "KeyValue.new("
          ruby << "separator: #{separator.inspect}" unless separator == ','

          if (keywords = to_ruby_keywords)
            ruby << ", #{keywords}"
          end

          ruby << ")"
          ruby
        end

      end
    end
  end
end
