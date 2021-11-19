require 'parslet'

module CommandMapper
  module Gen
    module Parsers
      class Common < Parslet::Parser

        rule(:space)  { match[' '] }
        rule(:spaces) { space.repeat(1) }
        rule(:space?) { space.maybe }

        rule(:ellipsis)  { str('...') }
        rule(:ellipsis?) { (space? >> ellipsis.as(:repeats)).maybe }

        rule(:capitalized_name) { match['A-Z'] >> match['a-z0-9_'].repeat(1) }
        rule(:lowercase_name)   { match['a-z'] >> match['a-z0-9_'].repeat(0) }
        rule(:uppercase_name)   { match['A-Z'] >> match['A-Z0-9_'].repeat(0) }

        rule(:short_flag) { str('-') >> match['a-zA-Z0-9#'] }
        rule(:long_flag) do
          str('--') >> match['a-zA-Z'] >> match['a-zA-Z0-9'].repeat(1) >> (
            match['_-'] >> match['a-zA-Z0-9'].repeat(1)
          ).repeat(0)
        end

      end
    end
  end
end
