module CommandMapper
  module Gen
    module Types
      class KeyValue

        def initialize(separator)
          @separator = separator
        end

        def to_ruby
          "KeyValue.new(#{separator.inspect})"
        end

      end
    end
  end
end
