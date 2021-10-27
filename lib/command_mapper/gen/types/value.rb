module CommandMapper
  module Gen
    module Types
      class Value

        # The `required` keyword.
        #
        # @return [Boolean, nil]
        attr_reader :required

        # The `allow_empty` keyword.
        #
        # @return [Boolean, nil]
        attr_reader :allow_empty

        # The `allow_blank` keyword.
        #
        # @return [Boolean, nil]
        attr_reader :allow_blank

        #
        # Initializes the value type.
        #
        # @param [Boolean, nil] required
        #   The `required` keyword value.
        #
        # @param [Boolean, nil] allow_empty
        #   The `allow_empty` keyword value.
        #
        # @param [Boolean, nil] allow_blank
        #   The `allow_blank` keyword value.
        #
        def initialize(required: nil, allow_empty: nil, allow_blank: nil)
          @required    = required
          @allow_empty = allow_empty
          @allow_blank = allow_blank
        end

        #
        # Converts the value type to Ruby keywords.
        #
        # @return [String, nil]
        #
        def to_ruby_keywords
          unless (@required.nil? && @allow_empty.nil? && @allow_blank.nil?)
            keywords = {}
            keywords[:required]    = @required    unless @required.nil?
            keywords[:allow_empty] = @allow_empty unless @allow_empty.nil?
            keywords[:allow_blank] = @allow_blank unless @allow_blank.nil?

            return keywords.map { |name,value|
              "#{name}: #{value.inspect}"
            }.join(', ') 
          end
        end

        #
        # Converts the value type to Ruby source code.
        #
        # @return [String, nil]
        #
        def to_ruby
          if (!@required.nil? && @allow_empty.nil? && @allow_blank.nil?)
            case @required
            when true  then ":required"
            when false then ":optional"
            end
          elsif (keywords = to_ruby_keywords)
            "{#{keywords}}"
          end
        end

      end
    end
  end
end
