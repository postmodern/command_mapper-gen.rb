module CommandMapper
  module Gen
    module Types
      class List

        #
        # Initializes the list type.
        #
        # @param [String] separator
        #   The separator character.
        #
        def initialize(separator: ',')
          @separator = separator
        end

        #
        # Converts the list type to Ruby source code.
        #
        # @return [String]
        #
        def to_ruby
          ruby = "List.new("
          ruby << "separator: #{separator.inspect}" unless separator == ','
          ruby << ")"
          ruby
        end

      end
    end
  end
end
