require 'command_mapper/gen/types/value'

module CommandMapper
  module Gen
    module Types
      class Num < Value

        #
        # Converts the num type to Ruby source code.
        #
        # @return [String]
        #
        def to_ruby
          ruby = "Num.new"

          if (keywords = to_ruby_keywords)
            ruby << "(#{keywords})"
          end

          ruby
        end

      end
    end
  end
end
