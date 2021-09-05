module CommandMapper
  module Gen
    #
    # Represents a mock `CommandMapper::ArgumentValue` base class.
    #
    class ArgumentValue

      # @return [Types::List, Types::KeyValue, nil]
      attr_reader :type

      # @return [Boolean, nil]
      attr_reader :required

      #
      # Initializes the argument value.
      #
      # @param [Types::List, Types::KeyValue, nil] type
      #
      # @param [Boolean, nil] required
      #
      def initialize(type: nil, required: nil)
        @type     = type
        @required = required
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
        ruby
      end

    end
  end
end
