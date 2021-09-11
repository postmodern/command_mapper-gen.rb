module CommandMapper
  module Gen
    module Formats
      class Map

        #
        # Initializes the map.
        #
        # @param [Hash{Object => String}] map
        #
        def initialize(map)
          @map = map
        end

        #
        # Converts the map format to Ruby source code.
        #
        # @return [String]
        #
        def to_ruby
          ruby = "Map.new("

          @map.each do |value,string|
            ruby << "#{value.inspect} => #{string.inspect}, "
          end

          ruby << ')'
          ruby
        end

      end
    end
  end
end
