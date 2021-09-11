module CommandMapper
  module Gen
    module Formats
      class List

        #
        # Initializes the list format.
        #
        # @param [String] separator
        #   The separator character.
        #
        def initialize(separator)
          @separator = separator
        end

        #
        # Converts the list format to Ruby source code.
        #
        # @return [String]
        #
        def to_ruby
          "List.new(#{separator.inspect})"
        end

      end
    end
  end
end
