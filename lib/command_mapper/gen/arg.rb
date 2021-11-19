module CommandMapper
  module Gen
    class Arg

      # @return [Boolean]
      attr_reader :required

      # The value configuration for the argument.
      #
      # @return [Types::Type, nil]
      attr_reader :type

      #
      # Initializes the parsed argument.
      #
      # @param [Boolean, nil] required
      #
      # @param [Types::Type, nil] type
      #
      def initialize(required: nil, type: nil)
        @required = required
        @type     = type
      end

      #
      # Converts the parsed argument to Ruby source code.
      #
      # @return [String]
      #
      def to_ruby
        ruby = []
        ruby << "required: #{@required.inspect}" if @required == false

        if (@type && (type = @type.to_ruby))
          ruby << "type: #{type}"
        end

        ruby.join(', ')
      end

    end
  end
end
