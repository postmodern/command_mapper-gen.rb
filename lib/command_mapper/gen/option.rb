require 'command_mapper/gen/option_value'

module CommandMapper
  module Gen
    #
    # Represents a parsed option.
    #
    class Option

      # The option flag for the option.
      #
      # @return [String]
      attr_reader :flag

      # @return [Boolean, nil]
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
      # @param [Boolean, nil] equals
      #
      # @param [Boolean, nil] repeats
      #
      # @param [Hash{Symbol => Object}, nil] value
      #
      def initialize(flag, equals: nil, repeats: nil, value: nil)
        @flag    = flag
        @equals  = equals
        @repeats = repeats

        @value = OptionValue.new(**value) if value
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

        ruby << ", equals: #{@equals}"         unless @equals.nil?
        ruby << ", repeats: #{@repeats}"       unless @repeats.nil?

        unless @value.nil?
          unless (value_keywords = @value.to_ruby).empty?
            ruby << ", value: {#{@value.to_ruby}}"
          else
            ruby << ", value: true"
          end
        end

        ruby << "\t# FIXME: #{fixme}" if fixme
        ruby
      end

    end
  end
end
