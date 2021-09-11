module CommandMapper
  module Gen
    #
    # Represents a mock `CommandMapper::ArgumentValue` base class.
    #
    class ArgumentValue

      # @return [Formats::List, Formats::KeyValue, nil]
      attr_reader :format

      # @return [Boolean, nil]
      attr_reader :required

      #
      # Initializes the argument value.
      #
      # @param [Formats::List, Formats::KeyValue, nil] format
      #
      # @param [Boolean, nil] required
      #
      def initialize(format: nil, required: nil)
        @format   = format
        @required = required
      end

      #
      # Converts the parsed option to Ruby source code.
      #
      # @return [String]
      #
      def to_ruby
        ruby = ""
        ruby << "format: #{@format.to_ruby}"         unless @format.nil?
        ruby << "required: #{@required.inspect}" unless @required.nil?
        ruby
      end

    end
  end
end
