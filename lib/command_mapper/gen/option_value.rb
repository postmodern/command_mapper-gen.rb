require 'command_mapper/gen/arg'
require 'command_mapper/gen/types/str'

module CommandMapper
  module Gen
    class OptionValue < Arg

      #
      # Converts the parsed option to Ruby source code.
      #
      # @return [String]
      #
      def to_ruby
        ruby = super()

        if ruby.empty? then "true"
        else                "{#{ruby}}"
        end
      end

    end
  end
end
