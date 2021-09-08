require 'parslet'

module CommandMapper
  module Gen
    module Parsers
      class Usage < Parslet::Parser

        rule(:space)  { str(' ')    }
        rule(:space?) { space.maybe }

        rule(:capitalized_name) { match['A-Z'] >> match['a-z0-9_'].repeat(1) }
        rule(:lowercase_name)   { match['a-z'] >> match['a-z0-9_'].repeat(0) }
        rule(:uppercase_name)   { match['A-Z'] >> match['A-Z0-9_'].repeat(0) }

        rule(:ellipsis)  { str('...') }
        rule(:ellipsis?) { (space? >> ellipsis.as(:repeats)).maybe }

        rule(:capitalized_word) { match['A-Z'] >> match['a-z'].repeat(1) }
        rule(:lowercase_word)   { match['a-z'].repeat(1)                 }
        rule(:word)             { capitalized_word | lowercase_word      }
        rule(:words) do
          (word >> (space >> word).repeat(1)).as(:words) >> ellipsis?
        end

        rule(:argument_name) do
          (
            (lowercase_name | uppercase_name).as(:name) >> ellipsis?
          ).as(:argument)
        end

        rule(:short_flag) do
          (str('-') >> match['a-zA-Z0-9#']).as(:short_flag)
        end

        rule(:short_flags) do
          (str('-') >> match['a-zA-Z0-9#'].repeat(2)).as(:short_flags)
        end

        rule(:long_flag) do
          (
            str('--') >> match['a-zA-Z'] >> match['a-zA-Z0-9_-'].repeat(0)
          ).as(:long_flag)
        end

        rule(:flag) do
          (long_flag | short_flags | short_flag)
        end

        rule(:option_value_string) do
          match['a-z0-9_-'].repeat(1).as(:string)
        end
        rule(:option_value_strings) do
          option_value_string >> (
            (str(',') >> option_value_string).repeat(1) |
            (str('|') >> option_value_string).repeat(1)
          )
        end

        rule(:option_value_name) do
          (lowercase_name | capitalized_name).as(:name) 
        end

        rule(:option_value) { option_value_strings | option_value_name }

        rule(:option_value_container) do
          (str('{') >> space? >> option_value >> space? >> str('}')) |
          (str('[') >> space? >> option_value >> space? >> str(']')) |
          (str('<') >> space? >> option_value >> space? >> str('>')) |
          option_value
        end

        rule(:option) do
          (
            flag >> (
              (space >> option_value_container) |
              (str('=').as(:equals) >> option_value_container) |
              (
                str('[') >> (
                  (str('=').as(:equals) >> option_value_container) |
                  option_value_container
                ) >> str(']')
              ).as(:optional)
            ).as(:value).maybe
          ).as(:option)
        end

        rule(:angle_brackets_group) do
          str('<') >> space? >>
            (words.as(:argument) | args) >>
          space? >> str('>')
        end

        rule(:curly_braces_group) do
          str('{') >> space? >>
            (words.as(:argument) | args) >>
          space? >> str('}')
        end

        rule(:optional_group) do
          str('[') >> space? >> args.as(:optional) >> space? >> str(']')
        end

        rule(:arg) do
          (
            # "-o" or "--opt"
            option |
            # "FOO" or "foo" or "foo-bar" or "foo_bar"
            argument_name |
            # "<...>"
            angle_brackets_group |
            # "{...}"
            curly_braces_group |
            # "[...]"
            optional_group
          ) >> ellipsis?
        end

        rule(:arg_separator) do
          (space >> (str('|') >> space).maybe)
        end
        rule(:args) { arg >> ( arg_separator >> arg).repeat(0) }

        rule(:command_name) do
          (match['a-zA-Z'] >> match['a-zA-Z0-9_-'].repeat(0)).as(:command_name)
        end

        rule(:usage) do
          command_name >> (space >> args).maybe
        end

        root :usage

      end
    end
  end
end
