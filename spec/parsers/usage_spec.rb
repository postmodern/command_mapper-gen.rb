require 'spec_helper'
require 'command_mapper/gen/parsers/usage'

describe CommandMapper::Gen::Parsers::Usage do
  describe "#capitalized_word" do
    subject { super().capitalized_word }

    context "when given a single lowercase character" do
      let(:string) { 'a' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given a '_' character" do
      let(:string) { '_' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given one uppercase character" do
      let(:string) { 'A' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given one uppercase character and a lowercase character" do
      let(:string) { 'Ab' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given one uppercase character followed by multiple lowercase characters" do
      let(:string) { 'Abbbb' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end

      context "and it contains a '_' character" do
        let(:string) { 'Abb_bb' }

        it "must not parse it" do
          expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
        end
      end

      context "and it contains a '-' character" do
        let(:string) { 'Abb-bb' }

        it "must not parse it" do
          expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
        end
      end
    end

    context "when given two uppercase characters" do
      let(:string) { 'AB' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#lowercase_word" do
    subject { super().lowercase_word }

    context "when given a '_' character" do
      let(:string) { '_' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given one lowercase character" do
      let(:string) { 'a' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given multiple lowercase characters" do
      let(:string) { 'ab' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
 
      context "and it contains a '_' character" do
        let(:string) { 'abb_bb' }

        it "must not parse it" do
          expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
        end
      end

      context "and it contains a '-' character" do
        let(:string) { 'Abb-bb' }

        it "must not parse it" do
          expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
        end
      end
    end

    context "when given a single uppercase characters" do
      let(:string) { 'A' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when it contains a uppercase character" do
      let(:string) { 'aaaaBaaaa' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#word" do
    subject { super().word }

    context "when given a lowercase word" do
      let(:string) { "foo" }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given a capitalized word" do
      let(:string) { "Foo" }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end
  end

  describe "#words" do
    subject { super().words }

    context "when given one word" do
      let(:word)   { "foo" }
      let(:string) { word  }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given two words" do
      let(:words)  { "foo bar" }
      let(:string) { words     }

      it "must capture the word" do
        expect(subject.parse(string)).to eq({words: words})
      end
    end

    context "when given more than two words separated by a space" do
      let(:words)  { "foo Bar baz" }
      let(:string) { words         }

      it "must capture the multiple words" do
        expect(subject.parse(string)).to eq({words: words})
      end
    end

    context "when the words end with '...'" do
      let(:words)  { "foo bar baz"  }
      let(:string) { "#{words} ..." }

      it "must capture the words and the ellipsis" do
        expect(subject.parse(string)).to eq({words: words, repeats: "..."})
      end
    end
  end

  describe "#argument_name" do
    subject { super().argument_name }

    context "when given a lowercase name" do
      let(:name)   { "foo" }
      let(:string) { name  }

      it "must capture the name" do
        expect(subject.parse(string)).to eq(
          {
            argument: {name: name}
          }
        )
      end

      context "and the string ends with a '...'" do
        let(:string) { "#{name} ..." }

        it "must capture the name and the ellipsis" do
          expect(subject.parse(string)).to eq(
            {
              argument: {
                name: name,
                repeats: "..."
              }
            }
          )
        end
      end
    end

    context "when given an uppercase name" do
      let(:name)   { "FOO" }
      let(:string) { name  }

      it "must capture the name" do
        expect(subject.parse(string)).to eq(
          {
            argument: {name: name}
          }
        )
      end

      context "and the string ends with a '...'" do
        let(:string) { "#{name} ..." }

        it "must capture the name and the ellipsis" do
          expect(subject.parse(string)).to eq(
            {
              argument: {
                name: name,
                repeats: "..."
              }
            }
          )
        end
      end
    end
  end

  describe "#short_flags" do
    subject { super().short_flags }

    context "when given a short flag (ex: '-o')" do
      let(:short_flag) { "-o"       }
      let(:string)     { short_flag }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given an amalgamation of short flags (ex: '-xyz')" do
      let(:short_flags) { "-xyz"      }
      let(:string)      { short_flags }

      it "must capture the short flags" do
        expect(subject.parse(string)).to eq({short_flags: short_flags})
      end
    end
  end

  describe "#flag" do
    subject { super().flag }

    context "when given a long flag (ex: '--opt')" do
      let(:long_flag) { "--opt"   }
      let(:string)    { long_flag }

      it "must capture the long flag" do
        expect(subject.parse(string)).to eq({long_flag: long_flag})
      end
    end

    context "when given a short flag (ex: '-o')" do
      let(:short_flag) { "-o"       }
      let(:string)     { short_flag }

      it "must capture the short flag" do
        expect(subject.parse(string)).to eq({short_flag: short_flag})
      end
    end

    context "when given an amalgamation of short flags (ex: '-xyz')" do
      let(:short_flags) { "-xyz"      }
      let(:string)      { short_flags }

      it "must capture the short flags" do
        expect(subject.parse(string)).to eq({short_flags: short_flags})
      end
    end
  end

  describe "#option_value_string" do
    subject { super().option_value_string }

    context "when given an empty string" do
      let(:string) { "" }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given one lowercase character" do
      let(:string) { 'a' }

      it "must capture the string" do
        expect(subject.parse(string)).to eq({string: string})
      end
    end

    context "when given multiple lowercase characters" do
      let(:string) { 'ab' }

      it "must capture the string" do
        expect(subject.parse(string)).to eq({string: string})
      end
 
      context "and it contains a '_' character" do
        let(:string) { 'a_b' }

        it "must capture the string" do
          expect(subject.parse(string)).to eq({string: string})
        end
      end

      context "and it contains a '-' character" do
        let(:string) { 'a-b' }

        it "must capture the string" do
          expect(subject.parse(string)).to eq({string: string})
        end
      end

      context "and when it contains an uppercase character" do
        let(:string) { 'aB' }

        it "must capture the string" do
          expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
        end
      end
    end
  end

  describe "#option_value_strings" do
    subject { super().option_value_strings }

    context "when given a single value string" do
      let(:string) { "foo" }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    let(:value_string1) { "foo" }
    let(:value_string2) { "bar" }

    context "when given two value strings" do
      context "and it's separated by a ','" do
        let(:string) { "#{value_string1},#{value_string2}" }

        it "must capture the strings" do
          expect(subject.parse(string)).to eq(
            [
              {string: value_string1},
              {string: value_string2}
            ]
          )
        end
      end

      context "and it's separated by a '|'" do
        let(:string) { "#{value_string1}|#{value_string2}" }

        it "must capture the strings" do
          expect(subject.parse(string)).to eq(
            [
              {string: value_string1},
              {string: value_string2}
            ]
          )
        end
      end
    end

    context "when given more than two value strings" do
      let(:value_string3) { "baz" }

      context "and it's separated by a ','" do
        let(:string) { "#{value_string1},#{value_string2},#{value_string3}" }

        it "must capture the strings" do
          expect(subject.parse(string)).to eq(
            [
              {string: value_string1},
              {string: value_string2},
              {string: value_string3}
            ]
          )
        end
      end

      context "and it's separated by a '|'" do
        let(:string) { "#{value_string1}|#{value_string2}|#{value_string3}" }

        it "must capture the strings" do
          expect(subject.parse(string)).to eq(
            [
              {string: value_string1},
              {string: value_string2},
              {string: value_string3}
            ]
          )
        end
      end

      context "but it's separated by a combination of ',' and '|'" do
        let(:string) { "#{value_string1},#{value_string2}|#{value_string3}" }

        it "must capture the strings" do
          expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
        end
      end
    end
  end

  describe "#option_value_name" do
    subject { super().option_value_name }

    context "when given a lowercase name" do
      let(:string) { 'foo' }

      it "must capture it" do
        expect(subject.parse(string)).to eq({name: string})
      end
    end

    context "when given a capitalized name" do
      let(:string) { 'Foo' }

      it "must capture it" do
        expect(subject.parse(string)).to eq({name: string})
      end
    end

    context "when given a camelCase name" do
      let(:string) { 'fooBar' }

      it "must capture it" do
        expect(subject.parse(string)).to eq({name: string})
      end
    end
  end

  describe "#option_value" do
    subject { super().option_value }

    context "when given multiple option value strings" do
      let(:value_string1) { "foo" }
      let(:value_string2) { "bar" }
      let(:value_string3) { "baz" }

      let(:string) { "#{value_string1},#{value_string2},#{value_string3}" }

      it "must capture the option value strings" do
        expect(subject.parse(string)).to eq(
          [
            {string: value_string1},
            {string: value_string2},
            {string: value_string3}
          ]
        )
      end
    end

    context "when given a single option value name" do
      let(:name)   { "foo" }
      let(:string) { name  }

      it "must capture the option value name" do
        expect(subject.parse(string)).to eq({name: name})
      end
    end
  end

  describe "#optional_option_value" do
    subject { super().optional_option_value }

    context "and the contents is an option value name" do
      let(:option_value_name) { "Foo" }
      let(:string) { "[#{option_value_name}]" }

      it "must parse the contents and mark it as optional" do
        expect(subject.parse(string)).to eq(
          {
            optional: {
              name: option_value_name
            }
          }
        )
      end
    end

    context "and the contents is an option value strings" do
      let(:value_string1) { "foo" }
      let(:value_string2) { "bar" }
      let(:value_string3) { "baz" }

      let(:option_value_strings) do
        "#{value_string1},#{value_string2},#{value_string3}"
      end

      let(:string) { "[#{option_value_strings}]" }

      it "must parse the contents and mark it as optional" do
        expect(subject.parse(string)).to eq(
          {
            optional: [
              {string: value_string1},
              {string: value_string2},
              {string: value_string3}
            ]
          }
        )
      end
    end
  end

  describe "#option_value_container" do
    subject { super().option_value_container }

    let(:value_string1) { "foo" }
    let(:value_string2) { "bar" }
    let(:value_string3) { "baz" }

    let(:option_value_strings) do
      "#{value_string1},#{value_string2},#{value_string3}"
    end

    let(:option_value_name) { "Foo" }

    context "when given a '{...}' string" do
      context "and the contents is an option value name" do
        let(:string) { "{#{option_value_name}}" }

        it "must parse the contents" do
          expect(subject.parse(string)).to eq({name: option_value_name})
        end
      end

      context "and the contents is an option value strings" do
        let(:string) { "{#{option_value_strings}}" }

        it "must parse the contents" do
          expect(subject.parse(string)).to eq(
            [
              {string: value_string1},
              {string: value_string2},
              {string: value_string3}
            ]
          )
        end
      end
    end

    context "when given a '<...>' string" do
      context "and the contents is an option value name" do
        let(:string) { "<#{option_value_name}>" }

        it "must parse the contents" do
          expect(subject.parse(string)).to eq({name: option_value_name})
        end
      end

      context "and the contents is an option value strings" do
        let(:string) { "<#{option_value_strings}>" }

        it "must parse the contents" do
          expect(subject.parse(string)).to eq(
            [
              {string: value_string1},
              {string: value_string2},
              {string: value_string3}
            ]
          )
        end
      end
    end

    context "when given a '[...]' string" do
      context "and the contents is an option value name" do
        let(:string) { "[#{option_value_name}]" }

        it "must parse the contents and mark it as optional" do
          expect(subject.parse(string)).to eq(
            {
              optional: {
                name: option_value_name
              }
            }
          )
        end
      end

      context "and the contents is an option value strings" do
        let(:string) { "[#{option_value_strings}]" }

        it "must parse the contents" do
          expect(subject.parse(string)).to eq(
            {
              optional: [
                {string: value_string1},
                {string: value_string2},
                {string: value_string3}
              ]
            }
          )
        end
      end
    end

    context "when given multiple option value strings" do
      let(:value_string1) { "foo" }
      let(:value_string2) { "bar" }
      let(:value_string3) { "baz" }

      let(:string) { "#{value_string1},#{value_string2},#{value_string3}" }

      it "must capture the option value strings" do
        expect(subject.parse(string)).to eq(
          [
            {string: value_string1},
            {string: value_string2},
            {string: value_string3}
          ]
        )
      end
    end

    context "when given a single option value name" do
      let(:name)   { "foo" }
      let(:string) { name  }

      it "must capture the option value name" do
        expect(subject.parse(string)).to eq({name: name})
      end
    end
  end

  describe "#option" do
    subject { super().option }

    context "when given an option flag" do
      let(:flag)   { "--opt" }
      let(:string) { flag    }

      it "must capture the option flag" do
        expect(subject.parse(string)).to eq(
          {
            option: {long_flag: flag}
          }
        )
      end

      context "and a value name separated by a space" do
        let(:name)   { 'value' }
        let(:string) { "#{flag} #{name}" }

        it "must capture the option flag and option value name" do
          expect(subject.parse(string)).to eq(
            {
              option: {
                long_flag: flag,
                value:     {name: name}
              }
            }
          )
        end
      end

      context "and a value name separated by a '='" do
        let(:name)   { 'value' }
        let(:string) { "#{flag}=#{name}" }

        it "must capture the option flag, equals, and the option value name" do
          expect(subject.parse(string)).to eq(
            {
              option: {
                long_flag: flag,
                value: {
                  equals: '=',
                  name:   name
                }
              }
            }
          )
        end

        context "but the '=' and value are wrapped in '[' and ']'" do
          let(:string) { "#{flag}[=#{name}]" }

          it "must mark the option value name and equals as being optional" do
            expect(subject.parse(string)).to eq(
              {
                option: {
                  long_flag: flag,
                  value: {
                    optional: {
                      equals: '=',
                      name:   name
                    }
                  }
                }
              }
            )
          end
        end
      end

      context "and an option value name wrapped in '[' ']'" do
        let(:name)   { 'value' }
        let(:string) { "#{flag}[#{name}]" }

        it "must mark the option value name and equals as being optional" do
          expect(subject.parse(string)).to eq(
            {
              option: {
                long_flag: flag,
                value: {
                  optional: {name: name}
                }
              }
            }
          )
        end
      end
    end
  end

  describe "#angle_brackets_group" do
    subject { super().angle_brackets_group }

    context "when given a string wrapped in '<' '>'" do
      context "and it contains a list of more than one word" do
        let(:words)  { "foo bar baz" }
        let(:string) { "<#{words}>"  }

        it "must capture the words as a single argument" do
          expect(subject.parse(string)).to eq(
            {
              argument: {words: words}
            }
          )
        end
      end

      context "and it contains more than one argument" do
        let(:arg1) { "FOO" }
        let(:arg2) { "BAR" }
        let(:arg3) { "BAZ" }
        let(:string) { "<#{arg1} #{arg2} #{arg3}>" }

        it "must capture the arguments" do
          expect(subject.parse(string)).to eq(
            [
              {argument: {name: arg1}},
              {argument: {name: arg2}},
              {argument: {name: arg3}},
            ]
          )
        end
      end
    end

    context "otherwise" do
      let(:string) { "foo bar" }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#curly_braces_group" do
    subject { super().curly_braces_group }

    context "when given a string wrapped in '{' '}'" do
      context "and it contains a list of more than one word" do
        let(:words)  { "foo bar baz" }
        let(:string) { "{#{words}}"  }

        it "must capture the words" do
          expect(subject.parse(string)).to eq(
            {
              argument: {words: words}
            }
          )
        end
      end

      context "and it contains more than one argument" do
        let(:arg1) { "FOO" }
        let(:arg2) { "BAR" }
        let(:arg3) { "BAZ" }
        let(:string) { "{#{arg1} #{arg2} #{arg3}}" }

        it "must capture the arguments" do
          expect(subject.parse(string)).to eq(
            [
              {argument: {name: arg1}},
              {argument: {name: arg2}},
              {argument: {name: arg3}},
            ]
          )
        end
      end
    end

    context "otherwise" do
      let(:string) { "foo bar" }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#optional_group" do
    subject { super().optional_group }

    context "when given a string wrapped in '[' ']'" do
      context "and it contains more than one argument" do
        let(:arg1) { "FOO" }
        let(:arg2) { "BAR" }
        let(:arg3) { "BAZ" }
        let(:string) { "[#{arg1} #{arg2} #{arg3}]" }

        it "must capture the arguments and mark them as optional" do
          expect(subject.parse(string)).to eq(
            {
              optional: [
                {argument: {name: arg1}},
                {argument: {name: arg2}},
                {argument: {name: arg3}}
              ]
            }
          )
        end

        context "and ends with a '...'" do
          let(:string) { "[#{arg1} #{arg2} #{arg3}]..." }

          it "must capture the arguments and mark them as optional" do
            expect(subject.parse(string)).to eq(
              {
                optional: [
                  {argument: {name: arg1}},
                  {argument: {name: arg2}},
                  {argument: {name: arg3}},
                  {repeats:  '...'}
                ]
              }
            )
          end
        end
      end
    end

    context "otherwise" do
      let(:string) { "foo bar" }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#arg" do
    subject { super().arg }

    context "when given an --option" do
      let(:flag)   { '--opt' }
      let(:string) { flag    }

      it "must capture the option" do
        expect(subject.parse(string)).to eq(
          {
            option: {long_flag: flag}
          }
        )
      end
    end

    context "when given an ARG name" do
      let(:name)   { 'ARG' }
      let(:string) { name  }

      it "must capture the argument name" do
        expect(subject.parse(string)).to eq(
          {
            argument: {name: name}
          }
        )
      end
    end

    let(:arg1) { "FOO" }
    let(:arg2) { "BAR" }
    let(:arg3) { "BAZ" }

    context "when given a <...> group of arguments" do
      let(:string) { "<#{arg1} #{arg2} #{arg3}>" }

      it "must capture the arguments" do
        expect(subject.parse(string)).to eq(
          [
            {argument: {name: arg1}},
            {argument: {name: arg2}},
            {argument: {name: arg3}},
          ]
        )
      end
    end

    context "when gvien a {...} group of arguments" do
      let(:string) { "{#{arg1} #{arg2} #{arg3}}" }

      it "must capture the arguments" do
        expect(subject.parse(string)).to eq(
          [
            {argument: {name: arg1}},
            {argument: {name: arg2}},
            {argument: {name: arg3}},
          ]
        )
      end
    end

    context "when given a [...] group of arguments" do
      let(:string) { "[#{arg1} #{arg2} #{arg3}]" }

      it "must parse the contents" do
        expect(subject.parse(string)).to eq(
          {
            optional: [
              {argument: {name: arg1}},
              {argument: {name: arg2}},
              {argument: {name: arg3}}
            ]
          }
        )
      end
    end

    context "when given a single '...'" do
      let(:string) { "..." }

      it "must parse the '...'" do
        expect(subject.parse(string)).to eq(string)
      end
    end
  end

  describe "#arg_separator" do
    subject { super().arg_separator }

    context "when given a ' '" do
      let(:string) { ' ' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given a ' | '" do
      let(:string) { ' | ' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given a '|'" do
      let(:string) { '|' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#args" do
    subject { super().args }

    context "when given one argument" do
      let(:arg)    { "ARG" }
      let(:string) { arg   }

      it "must parse the argument" do
        expect(subject.parse(string)).to eq({argument: {name: arg}})
      end
    end

    context "when given multiple arguments separated by a ' '" do
      let(:arg1)   { "ARG1" }
      let(:arg2)   { "ARG2" }
      let(:arg3)   { "ARG3" }
      let(:string) { "#{arg1} #{arg2} #{arg3}" }

      it "must parse the argument" do
        expect(subject.parse(string)).to eq(
          [
            {argument: {name: arg1}},
            {argument: {name: arg2}},
            {argument: {name: arg3}}
          ]
        )
      end
    end

    context "when given multiple arguments separated by a ' | '" do
      let(:arg1)   { "ARG1" }
      let(:arg2)   { "ARG2" }
      let(:arg3)   { "ARG3" }
      let(:string) { "#{arg1} | #{arg2} | #{arg3}" }

      it "must parse the argument" do
        expect(subject.parse(string)).to eq(
          [
            {argument: {name: arg1}},
            {argument: {name: arg2}},
            {argument: {name: arg3}}
          ]
        )
      end
    end
  end

  describe "#command_name" do
    subject { super().command_name }

    context "when the command name starts with a '_'" do
      let(:string) { '_foo' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when the command name starts with a '-'" do
      let(:string) { '-foo' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when the command name starts with a digit" do
      let(:string) { '0foo' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when the command name starts with a lowercase letter" do
      let(:string) { 'foo' }

      it "must capture the command name" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when the command name starts with a uppercase letter" do
      let(:string) { 'Foo' }

      it "must capture the command name" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when the command name contains a '_'" do
      let(:string) { 'foo_bar' }

      it "must capture the command name" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when the command name contains a '-'" do
      let(:string) { 'foo-bar' }

      it "must capture the command name" do
        expect(subject.parse(string)).to eq(string)
      end
    end
  end

  describe "#usage" do
    subject { super().usage }

    let(:command_name) { "foo" }

    context "when given only a command name" do
      let(:string) { command_name }

      it "must capture the command name" do
        expect(subject.parse(string)).to eq({command_name: command_name})
      end
    end

    context "when given a command name and a sub-command name" do
      let(:subcommand_name) { "bar" }

      let(:string) { "#{command_name} #{subcommand_name}" }

      it "must capture both the command name and sub-command name" do
        expect(subject.parse(string)).to eq(
          {
            command_name:    command_name,
            subcommand_name: subcommand_name
          }
        )
      end
    end

    context "when given a command name and a single argument" do
      let(:arg1)   { "ARG1" }
      let(:string) { "#{command_name} #{arg1}" }

      it "must capture the command name and argument" do
        expect(subject.parse(string)).to eq(
          {
            command_name: command_name,
            arguments: {argument: {name: arg1}}
          }
        )
      end
    end

    context "when given a command name and arguments" do
      let(:arg1)   { "ARG1" }
      let(:arg2)   { "ARG2" }
      let(:arg3)   { "ARG3" }
      let(:string) { "#{command_name} #{arg1} #{arg2} #{arg3}" }

      it "must capture the command name and arguments" do
        expect(subject.parse(string)).to eq(
          {
            command_name: command_name,
            arguments: [
              {argument: {name: arg1}},
              {argument: {name: arg2}},
              {argument: {name: arg3}}
            ]
          }
        )
      end
    end
  end
end
