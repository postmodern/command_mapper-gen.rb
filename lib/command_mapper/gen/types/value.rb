module CommandMapper
  module Gen
    module Types
      class Value

        # @return [Boolean, nil]
        attr_reader :required

        # @return [Boolean, nil]
        attr_reader :allow_empty

        # @return [Boolean, nil]
        attr_reader :allow_blank

        #
        # Initializes the value type.
        #
        # @param [Boolean, nil] required
        #
        # @param [Boolean, nil] allow_empty
        #
        # @param [Boolean, nil] allow_blank
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
          unless (@required.nil? && @allow_empty.nil? && @allow_blank)
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
          if (keywords = to_ruby_keywords)
            "{#{keywords}}"
          end
        end

      end
    end
  end
end
