module CommandMapper
  module Gen
    #
    # Represents the configuration keywords for the `ArgumentValue` base class.
    #
    class ArgumentValue

      # @return [Types::List, Types::KeyValue, nil]
      attr_reader :type

      # @return [Boolean, nil]
      attr_reader :required

      # @return [Boolean, nil]
      attr_reader :blank

      #
      # Initializes the argument value.
      #
      # @param [Types::List, Types::KeyValue, nil] type
      #
      # @param [Boolean, nil] required
      #
      # @param [Boolean, nil] blank
      #
      def initialize(type: nil, required: nil, blank: nil)
        @type     = type
        @required = required
        @blank    = blank
      end

      #
      # Converts the parsed option to Ruby source code.
      #
      # @return [String]
      #
      def to_ruby
        ruby = ""
        ruby << "type: #{@type.to_ruby}"         unless @type.nil?
        ruby << "required: #{@required.inspect}" unless @required.nil?
        ruby << "blank: #{@blank.inspect}"       unless @blank.nil?
        ruby
      end

    end
  end
end
