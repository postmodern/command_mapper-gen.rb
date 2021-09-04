module CommandMapper
  module Gen
    module Types
      class List

        def initialize(separator)
          @separator = separator
        end

        def to_ruby
          "List.new(#{separator.inspect})"
        end

      end
    end
  end
end
