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

        rule(:lowercase_name) do
          match['a-z'] >> match['a-z0-9'].repeat(0) >> (
            match['_-'] >> match['a-z0-9'].repeat(1)
          ).repeat(0)
        end

        rule(:uppercase_name) do
          match['A-Z'] >> match['A-Z0-9'].repeat(0) >> (
            match['_-'] >> match['A-Z0-9'].repeat(1)
          ).repeat(0)
        end

        rule(:camelcase_name) do
          match['a-z'] >> match['a-z0-9'].repeat(0) >> (
            match['A-Z'] >> match['a-z0-9'].repeat(1)
          ).repeat(1)
        end

        rule(:capitalized_name) do
          match['A-Z'] >> match['a-z0-9'].repeat(1) >> (
            match['_-'] >> match['a-z0-9'].repeat(1)
          ).repeat(0)
        end

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
