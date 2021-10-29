module CommandMapper
  module Gen
    class Arg

      # @return [Boolean]
      attr_reader :required

      # The value configuration for the argument.
      #
      # @return [Types::Type, nil]
      attr_reader :type

      # @return [Boolean, nil]
      attr_reader :repeats

      #
      # Initializes the parsed argument.
      #
      # @param [Boolean, nil] required
      #
      # @param [Types::Type, nil] type
      #
      # @param [Boolean, nil] repeats
      #
      def initialize(required: nil, type: nil, repeats: nil)
        @required = required
        @type     = type
        @repeats  = repeats
      end

      #
      # Converts the parsed argument to Ruby source code.
      #
      # @return [String]
      #
      def to_ruby
        ruby = []
        ruby << "required: #{@required.inspect}" if @required == false
        ruby << "type: #{@type.to_ruby}"         unless @type.nil?
        ruby << "repeats: #{@repeats.inspect}"   unless @repeats.nil?
        ruby.join(', ')
      end

    end
  end
end
