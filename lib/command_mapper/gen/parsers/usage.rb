require 'command_mapper/gen/parsers/common'

module CommandMapper
  module Gen
    module Parsers
      class Usage < Common

        rule(:capitalized_word) { match['A-Z'] >> match['a-z'].repeat(1) }
        rule(:lowercase_word)   { match['a-z'].repeat(1)                 }
        rule(:word)             { capitalized_word | lowercase_word      }
        rule(:words) do
          (word >> (space >> word).repeat(1)).as(:words) >> ellipsis?
        end

        rule(:ignored_argument_names) do
          str("OPTIONS") | str('OPTS') | str("options") | str('opts')
        end

        rule(:argument_name) do
          (
            (
              (uppercase_name | capitalized_name | lowercase_name) >>
              (space >> ignored_argument_names).maybe
            ).as(:name) >> ellipsis?
          ).as(:argument)
        end

        rule(:short_flags) do
          (str('-') >> match['a-zA-Z0-9#'].repeat(2)).as(:short_flags)
        end

        rule(:flag) do
          (long_flag.as(:long_flag) | short_flags | short_flag.as(:short_flag))
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
          (camelcase_name | lowercase_name | capitalized_name).as(:name) 
        end

        rule(:option_value) { option_value_strings | option_value_name }

        rule(:optional_option_value) do
          str('[') >> space? >>
            option_value.as(:optional) >>
          space? >> str(']')
        end

        rule(:option_value_container) do
          (str('{') >> space? >> option_value >> space? >> str('}')) |
          (str('<') >> space? >> option_value >> space? >> str('>')) |
          optional_option_value |
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
          (
            str('[') >> space? >>
              args >>
            space? >> str(']') >> ellipsis?
          ).as(:optional)
        end

        rule(:dash) { match['-'].repeat(1,2) }

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
            optional_group |
            # "..."
            ellipsis |
            # "--" or "-"
            dash
          )
        end

        rule(:arg_separator) do
          str('|') | (space >> (str('|') >> space).maybe)
        end
        rule(:args) { arg >> ( arg_separator >> arg).repeat(0) }

        rule(:subcommand_name) { match['a-z'] >> match['a-z0-9_-'].repeat(0) }
        rule(:command_name) { match['a-zA-Z'] >> match['a-z0-9_-'].repeat(0) }

        rule(:usage) do
          command_name.as(:command_name) >>
          (space >> subcommand_name.as(:subcommand_name)).maybe >>
          (space >> args.as(:arguments)).maybe
        end

        root :usage

      end
    end
  end
end
