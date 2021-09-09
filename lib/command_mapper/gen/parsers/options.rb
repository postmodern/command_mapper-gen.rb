require 'command_mapper/gen/parsers/common'

module CommandMapper
  module Gen
    module Parsers
      class Options < Common

        rule(:name) { lowercase_name | capitalized_name | uppercase_name }

        rule(:literal_values) do
          (
            name.as(:string) >> (str('|') >> name.as(:string)).repeat(1)
          ).as(:literal_values)
        end

        rule(:list) do
          (
            name.as(:name) >> (
              (str(',').as(:separator) >> ellipsis) |
              (str('[') >> str(',').as(:separator) >> ellipsis >> str(']'))
            )
          ).as(:list)
        end

        rule(:key_value) do
          (
            name >>
            match[':='].as(:separator) >>
            (name | ellipsis)
          ).as(:key_value)
        end

        rule(:value) do
          (
            # "FOO,..."
            list |
            # "KEY:VALUE" or "KEY=VALUE"
            key_value |
            # "FOO|..." or "foo|..."
            literal_values |
            # "FOO" or "foo"
            name.as(:name)
          ).as(:value)
        end

        rule(:angle_brackets) do
          str('<') >> space? >> value >> space? >> str('>')
        end

        rule(:curly_braces) do
          str('{') >> space? >> value >> space? >> str('}')
        end

        rule(:square_brackets) do
          (
            str('[') >> space? >>
            value >>
            space? >> str(']')
          ).as(:optional)
        end

        rule(:value_container) do
          # "{...}"
          curly_braces |
          # "<...>"
          angle_brackets |
          # "[...]"
          square_brackets |
          # "..."
          value
        end

        rule(:option_value) do
          # " VALUE"
          (space >> value_container) |
          # "=VALUE"
          (str('=').as(:equals) >> value_container) |
          (
            str('[') >> (
              # "[=VALUE]"
              (str('=').as(:equals) >> value_container) |
              # "[VALUE]"
              value_container
            ) >> str(']')
          ).as(:optional)
        end

        rule(:long_option) do
          # "--option" or "--option VALUE" or "--option=VALUE"
          long_flag.as(:long_flag) >> option_value.maybe
        end

        rule(:option_separator) { str(', ') }

        rule(:short_and_long_option) do
          # "-o, --option" or "-o, --option VALUE" or "-o, --option=VALUE"
          short_flag.as(:short_flag) >>
            option_separator >> long_flag.as(:long_flag) >>
            (option_separator >> long_flag).repeat(0) >>
            option_value.maybe
        end

        rule(:short_option) do
          # "-o" or "-o VALUE" or "-o=VALUE"
          short_flag.as(:short_flag) >> option_value.maybe
        end

        rule(:option) { long_option | short_and_long_option | short_option }

        rule(:option_summary) { any.repeat(1) }

        rule(:option_line) do
          (str("\t") | spaces) >> option >> str(',').maybe >>
          (match[' \t'].repeat(1) >> option_summary).maybe >> any.absent?
        end

        root :option_line

      end
    end
  end
end
