module CommandMapper
  module Gen
    module Types
      class Map

        # @return [Hash{Object => String}]
        attr_reader :map

        #
        # Initializes the map type.
        #
        # @param [Hash{Object => String}] map
        #
        def initialize(map)
          @map = map
        end

        #
        # Converts the map type to Ruby source code.
        #
        # @return [String]
        #
        def to_ruby
          ruby = "Map.new("
          @map.each do |value,string|
            ruby << "#{value.inspect} => #{string.inspect}, "
          end
          ruby << ")"
          ruby
        end

      end
    end
  end
end
