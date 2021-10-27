require 'command_mapper/gen/types/value'

module CommandMapper
  module Gen
    module Types
      class Map < Value

        # @return [Hash{Object => String}]
        attr_reader :map

        #
        # Initializes the map type.
        #
        # @param [Hash{Object => String}] map
        #
        def initialize(map, **kwargs)
          super(**kwargs)

          @map = map
        end

        #
        # Converts the map type to Ruby source code.
        #
        # @return [String]
        #
        def to_ruby
          ruby = "Map.new("

          ruby << "{"
          @map.each do |value,string|
            ruby << "#{value.inspect} => #{string.inspect}, "
          end
          ruby << "}"

          if (keywords = to_ruby_keywords)
            ruby << ", #{keywords}"
          end

          ruby << ')'
          ruby
        end

      end
    end
  end
end
