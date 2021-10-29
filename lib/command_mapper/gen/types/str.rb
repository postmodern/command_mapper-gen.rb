module CommandMapper
  module Gen
    module Types
      class Str

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
        # @param [Boolean, nil] allow_empty
        #   The `allow_empty` keyword value.
        #
        # @param [Boolean, nil] allow_blank
        #   The `allow_blank` keyword value.
        #
        def initialize(allow_empty: nil, allow_blank: nil)
          @allow_empty = allow_empty
          @allow_blank = allow_blank
        end

        #
        # Converts the value type to Ruby source code.
        #
        # @return [String, nil]
        #
        def to_ruby
          unless (@allow_empty.nil? && @allow_blank.nil?)
            keywords = []

            keywords << "allow_empty: #{@allow_empty.inspect}" unless @allow_empty.nil?
            keywords << "allow_blank: #{@allow_blank.inspect}" unless @allow_blank.nil?
            keywords.join(', ')
          end
        end

      end
    end
  end
end
