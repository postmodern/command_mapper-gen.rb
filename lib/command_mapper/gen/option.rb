require 'command_mapper/gen/option_value'

module CommandMapper
  module Gen
    #
    # Represents a mock `CommandMapper::Option` class.
    #
    class Option

      # The option flag for the option.
      #
      # @return [String]
      attr_reader :flag

      # @return [Boolean, :equals, nil]
      attr_reader :equals

      # @return [Boolean, nil]
      attr_reader :repeats

      # @return [OptionValue, nil]
      attr_reader :value

      #
      # Initializes the parsed argument.
      #
      # @param [String] flag
      #   The option flag.
      #
      # @param [Boolean, :optional, nil] equals
      #
      # @param [Boolean, nil] repeats
      #
      # @param [Hash{Symbol => Object}, nil] value
      #
      def initialize(flag, equals: nil, repeats: nil, value: nil)
        @flag    = flag
        @equals  = equals
        @value   = OptionValue.new(**value) if value
        @repeats = repeats
      end

      #
      # Converts the parsed option to Ruby source code.
      #
      # @return [String]
      #
      def to_ruby
        ruby = "option #{@flag.inspect}"
        fixme = nil

        if @flag =~ /^-[a-zA-Z0-9]/ && @flag.length <= 3
          ruby << ", name: "
          fixme = "name"
        end

        ruby << ", equals: #{@equals.inspect}"   unless @equals.nil?
        ruby << ", repeats: #{@repeats.inspect}" unless @repeats.nil?
        ruby << ", value: #{@value.to_ruby}" if @value
        ruby << "\t# FIXME: #{fixme}" if fixme
        ruby
      end

    end
  end
end
