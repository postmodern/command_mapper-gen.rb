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
        if @required && @type.nil? || (@type.kind_of?(Types::Str) && 
                                       @type.allow_empty.nil? &&
                                       @type.allow_blank.nil?)
          "true"
        else
        "{#{super}}"
        end
      end

    end
  end
end
