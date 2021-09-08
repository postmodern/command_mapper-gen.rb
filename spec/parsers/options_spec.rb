require 'spec_helper'
require 'command_mapper/gen/parsers/options'

describe CommandMapper::Gen::Parsers::Options do
  describe "#name" do
    subject { super().name.parse(name) }

    context "when given a uppercase name" do
      context "and it's a single character" do
        let(:name) { 'A' }

        it "must parse it" do
          expect(subject).to eq(name)
        end
      end

      context "and it's multiple characters" do
        let(:name) { 'ABC' }

        it "must parse it" do
          expect(subject).to eq(name)
        end

        context "but it starts with a digit" do
          let(:name) { '1FOO' }

          it "must not parse it" do
            expect { subject }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a digit" do
          let(:name) { 'FOO1' }

          it "must not parse it" do
            expect(subject).to eq(name)
          end
        end

        context "but it starts with a '_'" do
          let(:name) { '_FOO' }

          it "must not parse it" do
            expect { subject }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a '_'" do
          let(:name) { 'FOO_BAR' }

          it "must parse it" do
            expect(subject).to eq(name)
          end
        end

        context "but it contains a '-'" do
          let(:name) { 'FOO-BAR' }

          it "must not parse it" do
            expect { subject }.to raise_error(Parslet::ParseFailed)
          end
        end
      end
    end

    context "when given a lowercase name" do
      context "and it's a single character" do
        let(:name) { 'a' }

        it "must parse it" do
          expect(subject).to eq(name)
        end
      end

      context "and it's multiple characters" do
        let(:name) { 'abc' }

        it "must parse it" do
          expect(subject).to eq(name)
        end

        context "but it starts with a digit" do
          let(:name) { '1foo' }

          it "must not parse it" do
            expect { subject }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a digit" do
          let(:name) { 'foo1' }

          it "must not parse it" do
            expect(subject).to eq(name)
          end
        end

        context "but it starts with a '_'" do
          let(:name) { '_foo' }

          it "must not parse it" do
            expect { subject }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a '_'" do
          let(:name) { 'foo_bar' }

          it "must parse it" do
            expect(subject).to eq(name)
          end
        end

        context "and it contains a '-'" do
          let(:name) { 'foo-bar' }

          it "must not parse it" do
            expect { subject }.to raise_error(Parslet::ParseFailed)
          end
        end
      end
    end

    context "when given a capitalized name" do
      context "and it's multiple characters" do
        let(:name) { 'Abc' }

        it "must parse it" do
          expect(subject).to eq(name)
        end

        context "but it starts with a digit" do
          let(:name) { '1Foo' }

          it "must not parse it" do
            expect { subject }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a digit" do
          let(:name) { 'Foo1' }

          it "must not parse it" do
            expect(subject).to eq(name)
          end
        end

        context "but it starts with a '_'" do
          let(:name) { '_Foo' }

          it "must not parse it" do
            expect { subject }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a '_'" do
          let(:name) { 'Foo_bar' }

          it "must parse it" do
            expect(subject).to eq(name)
          end
        end

        context "and it contains a '-'" do
          let(:name) { 'Foo-bar' }

          it "must not parse it" do
            expect { subject }.to raise_error(Parslet::ParseFailed)
          end
        end
      end
    end
  end

  describe "#literal_values" do
    subject { super().literal_values.parse(string) }

    context "when given 'foo'" do
      let(:string)   { "foo" }

      it "must not parse the single name" do
        expect { subject }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given 'foo|bar'" do
      let(:literal1) { "foo" }
      let(:literal2) { "bar" }
      let(:string)   { "#{literal1}|#{literal2}" }

      it "must parse both literal string values" do
        expect(subject).to eq(
          {
            literal_values: [
              {string: literal1},
              {string: literal2}
            ]
          }
        )
      end
    end

    context "when given 'foo|bar|baz'" do
      let(:literal1) { "foo" }
      let(:literal2) { "bar" }
      let(:literal3) { "baz" }
      let(:string)   { "#{literal1}|#{literal2}|#{literal3}" }

      it "must parse both literal string values" do
        expect(subject).to eq(
          {
            literal_values: [
              {string: literal1},
              {string: literal2},
              {string: literal3}
            ]
          }
        )
      end
    end
  end

  describe "#list" do
    subject { super().list.parse(string) }

    context "when given 'VALUE,...'" do
      let(:separator) { ',' }
      let(:name)      { "ITEM" }
      let(:string)    { "#{name}#{separator}..." }

      it "must parse the list item name and separator" do
        expect(subject).to eq(
          {
            list: {
              name:      name,
              separator: separator
            }
          }
        )
      end
    end
  end

  describe "#key_value" do
    subject { super().key_value.parse(string) }

    context "when given 'KEY:VALUE'" do
      let(:separator) { ':' }
      let(:string)    { "key#{separator}value" }

      it "must parse the key:value and separator" do
        expect(subject).to eq({key_value: {separator: separator}})
      end
    end

    context "when given 'KEY=VALUE'" do
      let(:separator) { '=' }
      let(:string)    { "key#{separator}value" }

      it "must parse the key:value and separator" do
        expect(subject).to eq({key_value: {separator: separator}})
      end
    end
  end

  describe "#value" do
    subject { super().value.parse(string) }

    context "when given 'NAME,...'" do
      let(:name)   { "NAME"        }
      let(:string) { "#{name},..." }

      it "must parse the value as a list" do
        expect(subject).to eq(
          {
            value: {
              list: {name: name, separator: ','}
            }
          }
        )
      end
    end

    context "when given 'KEY:VALUE'" do
      let(:key)       { "NAME"            }
      let(:value)     { "VALUE"           }
      let(:separator) { ':'               }
      let(:string)    { "#{key}#{separator}#{value}" }

      it "must parse the value as a list" do
        expect(subject).to eq(
          {
            value: {
              key_value: {separator: separator}
            }
          }
        )
      end
    end

    context "when given 'KEY=VALUE'" do
      let(:key)       { "NAME"            }
      let(:value)     { "VALUE"           }
      let(:separator) { '='               }
      let(:string)    { "#{key}#{separator}#{value}" }

      it "must parse the value as a list" do
        expect(subject).to eq(
          {
            value: {
              key_value: {separator: separator}
            }
          }
        )
      end
    end

    context "when given 'str1|...'" do
      let(:str1) { 'str1' }
      let(:str2) { 'str2' }
      let(:string) { "#{str1}|#{str2}" }

      it "must parse the list of literal string values" do
        expect(subject).to eq(
          {
            value: {
              literal_values: [
                {string: str1},
                {string: str2}
              ]
            }
          }
        )
      end
    end

    context "when given 'name" do
      let(:name)   { 'name' }
      let(:string) { name   }

      it "must parse the option's value name" do
        expect(subject).to eq({value: {name: name}})
      end
    end

    context "when given 'NAME" do
      let(:name)   { 'NAME' }
      let(:string) { name   }

      it "must parse the option's value name" do
        expect(subject).to eq({value: {name: name}})
      end
    end
  end

  describe "#value_container" do
    subject { super().value_container.parse(string) }

    context "when given '{NAME}'" do
      let(:name)   { "NAME"      }
      let(:string) { "{#{name}}" }

      it "must parse the value within the { }" do
        expect(subject).to eq({value: {name: name}})
      end
    end

    context "when given '<VALUE>'" do
      let(:name)   { "NAME"      }
      let(:string) { "<#{name}>" }

      it "must parse the value within the < >" do
        expect(subject).to eq({value: {name: name}})
      end
    end

    context "when given '[VALUE]'" do
      let(:name)   { "NAME"      }
      let(:string) { "[#{name}]" }

      it "must parse the optional value within the [ ]" do
        expect(subject).to eq(
          {
            optional: {
              value: {name: name}
            }
          }
        )
      end
    end

    context "when given 'VALUE'" do
      let(:name)   { "NAME"    }
      let(:string) { "#{name}" }

      it "must return the value" do
        expect(subject).to eq({value: {name: name}})
      end
    end
  end

  describe "#option" do
    let(:short_flag) { '-o'    }
    let(:long_flag)  { '--opt' }
    let(:value)      { 'VALUE' }

    subject { super().option.parse(string) }

    context "when given '-o'" do
      let(:string) { short_flag }

      it "must capture the short flag" do
        expect(subject).to eq({short_flag: short_flag})
      end
    end

    context "when given '-o VALUE'" do
      let(:string) { "#{short_flag} #{value}" }

      it "must capture short flag and argument name" do
        expect(subject).to eq(
          {
            short_flag: short_flag,
            value: {name: value}
          }
        )
      end
    end

    context "when given '-o=VALUE'" do
      let(:string) { "#{short_flag}=#{value}" }

      it "must capture the short flag, equals, and value" do
        expect(subject).to eq(
          {
            short_flag: short_flag,
            equals: '=',
            value: {name: value}
          }
        )
      end
    end

    context "when given '--opt'" do
      let(:string) { long_flag }

      it "must capture the long flag" do
        expect(subject).to eq(
          {
            long_flag: long_flag
          }
        )
      end
    end

    context "when given '--opt VALUE'" do
      let(:string) { "#{long_flag} #{value}" }

      it "must capture the long flag and value" do
        expect(subject).to eq(
          {
            long_flag: long_flag,
            value: {name: value}
          }
        )
      end
    end

    context "when given '--opt=VALUE'" do
      let(:string) { "#{long_flag}=#{value}" }

      it "must capture the long flag, equals, and value" do
        expect(subject).to eq(
          {
            long_flag: long_flag,
            equals: '=',
            value: {name: value}
          }
        )
      end
    end

    context "when given '-o, --opt'" do
      let(:string) { "#{short_flag}, #{long_flag}" }

      it "must capture the short flag and long flag" do
        expect(subject).to eq(
          {
            short_flag: short_flag,
            long_flag:  long_flag
          }
        )
      end
    end

    context "when given '-o, --opt1, --opt2, --opt3'" do
      let(:long_Flag) { "--opt1" }
      let(:string) { "#{short_flag}, #{long_flag}, --opt2, --opt3" }

      it "must only capture the short flag and first long flag" do
        expect(subject).to eq(
          {
            short_flag: short_flag,
            long_flag:  long_flag
          }
        )
      end
    end

    context "when given '-o, --opt VALUE'" do
      let(:string) { "#{short_flag}, #{long_flag} #{value}" }

      it "must capture the short flag, long flag, and value" do
        expect(subject).to eq(
          {
            short_flag: short_flag,
            long_flag:  long_flag,
            value: {name: value}
          }
        )
      end
    end

    context "when given '-o, --opt=VALUE'" do
      let(:string) { "#{short_flag}, #{long_flag}=#{value}" }

      it "must capture the short flag, long flag, equals, and value" do
        expect(subject).to eq(
          {
            short_flag: short_flag,
            long_flag:  long_flag,
            equals: '=',
            value: {name: value}
          }
        )
      end
    end
  end

  describe "#option_line" do
    subject { super().option_line.parse(line) }

    let(:short_flag) { '-o'    }
    let(:long_flag)  { '--opt' }
    let(:value)      { 'VALUE' }

    context "when given a line only containing options" do
      let(:line) { "    #{short_flag}, #{long_flag}=#{value}" }

      it "must parse the options" do
        expect(subject).to eq(
          {
            short_flag: short_flag,
            long_flag:  long_flag,
            equals: '=',
            value: {name: value}
          }
        )
      end
    end

    context "when the line begins with a single space" do
      let(:line) { " #{short_flag}, #{long_flag}=#{value}" }

      it "must parse the options" do
        expect(subject).to eq(
          {
            short_flag: short_flag,
            long_flag:  long_flag,
            equals: '=',
            value: {name: value}
          }
        )
      end
    end

    context "when the line begins with multiple spaces" do
      let(:line) { "    #{short_flag}, #{long_flag}=#{value}" }

      it "must parse the options" do
        expect(subject).to eq(
          {
            short_flag: short_flag,
            long_flag:  long_flag,
            equals: '=',
            value: {name: value}
          }
        )
      end
    end

    context "when the line begins with a single tab" do
      let(:line) { "\t#{short_flag}, #{long_flag}=#{value}" }

      it "must parse the options" do
        expect(subject).to eq(
          {
            short_flag: short_flag,
            long_flag:  long_flag,
            equals: '=',
            value: {name: value}
          }
        )
      end
    end

    context "when given a line with trailing option summary text" do
      let(:summary) { 'Does stuff and stuff.' }
      let(:line)    { "  #{short_flag}, #{long_flag}=#{value}\t#{summary}" }

      it "must parse the options and ignore the summary text" do
        expect(subject).to eq(
          {
            short_flag: short_flag,
            long_flag:  long_flag,
            equals: '=',
            value: {name: value}
          }
        )
      end

      context "and the summary is indented with multiple spaces" do
        let(:line)    { "  #{short_flag}, #{long_flag}=#{value}  #{summary}" }

        it "must parse the options and ignore the summary text" do
          expect(subject).to eq(
            {
              short_flag: short_flag,
              long_flag:  long_flag,
              equals: '=',
              value: {name: value}
            }
          )
        end
      end

      context "and the summary is indented with a single tab" do
        let(:line)    { "  #{short_flag}, #{long_flag}=#{value}\t#{summary}" }

        it "must parse the options and ignore the summary text" do
          expect(subject).to eq(
            {
              short_flag: short_flag,
              long_flag:  long_flag,
              equals: '=',
              value: {name: value}
            }
          )
        end
      end

      context "and the summary is indented with a both tabs and spaces" do
        let(:line)    { "  #{short_flag}, #{long_flag}=#{value}\t  #{summary}" }

        it "must parse the options and ignore the summary text" do
          expect(subject).to eq(
            {
              short_flag: short_flag,
              long_flag:  long_flag,
              equals: '=',
              value: {name: value}
            }
          )
        end
      end
    end
  end
end
