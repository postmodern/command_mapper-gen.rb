require 'spec_helper'
require 'command_mapper/gen/parsers/options'

describe CommandMapper::Gen::Parsers::Options do
  describe "#name" do
    subject { super().name }

    context "when given a uppercase name" do
      context "and it's a single character" do
        let(:string) { 'A' }

        it "must parse it" do
          expect(subject.parse(string)).to eq(string)
        end
      end

      context "and it's multiple characters" do
        let(:string) { 'ABC' }

        it "must parse it" do
          expect(subject.parse(string)).to eq(string)
        end

        context "but it starts with a digit" do
          let(:string) { '1FOO' }

          it "must not parse it" do
            expect {
              subject.parse(string)
            }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a digit" do
          let(:string) { 'FOO1' }

          it "must not parse it" do
            expect(subject.parse(string)).to eq(string)
          end
        end

        context "but it starts with a '_'" do
          let(:string) { '_FOO' }

          it "must not parse it" do
            expect {
              subject.parse(string)
            }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a '_'" do
          let(:string) { 'FOO_BAR' }

          it "must parse it" do
            expect(subject.parse(string)).to eq(string)
          end
        end

        context "but it contains a '-'" do
          let(:string) { 'FOO-BAR' }

          it "must not parse it" do
            expect {
              subject.parse(string)
            }.to raise_error(Parslet::ParseFailed)
          end
        end
      end
    end

    context "when given a lowercase name" do
      context "and it's a single character" do
        let(:string) { 'a' }

        it "must parse it" do
          expect(subject.parse(string)).to eq(string)
        end
      end

      context "and it's multiple characters" do
        let(:string) { 'abc' }

        it "must parse it" do
          expect(subject.parse(string)).to eq(string)
        end

        context "but it starts with a digit" do
          let(:string) { '1foo' }

          it "must not parse it" do
            expect {
              subject.parse(string)
            }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a digit" do
          let(:string) { 'foo1' }

          it "must not parse it" do
            expect(subject.parse(string)).to eq(string)
          end
        end

        context "but it starts with a '_'" do
          let(:string) { '_foo' }

          it "must not parse it" do
            expect {
              subject.parse(string)
            }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a '_'" do
          let(:string) { 'foo_bar' }

          it "must parse it" do
            expect(subject.parse(string)).to eq(string)
          end
        end

        context "and it contains a '-'" do
          let(:string) { 'foo-bar' }

          it "must not parse it" do
            expect {
              subject.parse(string)
            }.to raise_error(Parslet::ParseFailed)
          end
        end
      end
    end

    context "when given a capitalized name" do
      context "and it's multiple characters" do
        let(:string) { 'Abc' }

        it "must parse it" do
          expect(subject.parse(string)).to eq(string)
        end

        context "but it starts with a digit" do
          let(:string) { '1Foo' }

          it "must not parse it" do
            expect {
              subject.parse(string)
            }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a digit" do
          let(:string) { 'Foo1' }

          it "must not parse it" do
            expect(subject.parse(string)).to eq(string)
          end
        end

        context "but it starts with a '_'" do
          let(:string) { '_Foo' }

          it "must not parse it" do
            expect {
              subject.parse(string)
            }.to raise_error(Parslet::ParseFailed)
          end
        end

        context "and it contains a '_'" do
          let(:string) { 'Foo_bar' }

          it "must parse it" do
            expect(subject.parse(string)).to eq(string)
          end
        end

        context "and it contains a '-'" do
          let(:string) { 'Foo-bar' }

          it "must not parse it" do
            expect {
              subject.parse(string)
            }.to raise_error(Parslet::ParseFailed)
          end
        end
      end
    end
  end

  describe "#literal_values" do
    subject { super().literal_values }

    context "when given 'foo'" do
      let(:string)   { "foo" }

      it "must not parse the single name" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given 'foo|bar'" do
      let(:literal1) { "foo" }
      let(:literal2) { "bar" }
      let(:string)   { "#{literal1}|#{literal2}" }

      it "must parse both literal string values" do
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
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
    subject { super().list }

    context "when given 'VALUE,...'" do
      let(:separator) { ',' }
      let(:name)      { "ITEM" }
      let(:string)    { "#{name}#{separator}..." }

      it "must parse the list item name and separator" do
        expect(subject.parse(string)).to eq(
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
    subject { super().key_value }

    context "when given 'KEY:VALUE'" do
      let(:separator) { ':' }
      let(:string)    { "key#{separator}value" }

      it "must parse the key:value and separator" do
        expect(subject.parse(string)).to eq(
          {
            key_value: {separator: separator}
          }
        )
      end
    end

    context "when given 'KEY=VALUE'" do
      let(:separator) { '=' }
      let(:string)    { "key#{separator}value" }

      it "must parse the key:value and separator" do
        expect(subject.parse(string)).to eq(
          {
            key_value: {separator: separator}
          }
        )
      end
    end
  end

  describe "#value" do
    subject { super().value }

    context "when given 'NAME,...'" do
      let(:name)   { "NAME"        }
      let(:string) { "#{name},..." }

      it "must parse the value as a list" do
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq({value: {name: name}})
      end
    end

    context "when given 'NAME" do
      let(:name)   { 'NAME' }
      let(:string) { name   }

      it "must parse the option's value name" do
        expect(subject.parse(string)).to eq({value: {name: name}})
      end
    end
  end

  describe "#value_container" do
    subject { super().value_container }

    context "when given '{NAME}'" do
      let(:name)   { "NAME"      }
      let(:string) { "{#{name}}" }

      it "must parse the value within the { }" do
        expect(subject.parse(string)).to eq(
          {
            value: {name: name}
          }
        )
      end
    end

    context "when given '<VALUE>'" do
      let(:name)   { "NAME"      }
      let(:string) { "<#{name}>" }

      it "must parse the value within the < >" do
        expect(subject.parse(string)).to eq(
          {
            value: {name: name}
          }
        )
      end
    end

    context "when given '[VALUE]'" do
      let(:name)   { "NAME"      }
      let(:string) { "[#{name}]" }

      it "must parse the optional value within the [ ]" do
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
          {
            value: {name: name}
          }
        )
      end
    end
  end

  describe "#option" do
    let(:short_flag) { '-o'    }
    let(:long_flag)  { '--opt' }
    let(:value)      { 'VALUE' }

    subject { super().option }

    context "when given '-o'" do
      let(:string) { short_flag }

      it "must capture the short flag" do
        expect(subject.parse(string)).to eq({short_flag: short_flag})
      end
    end

    context "when given '-o VALUE'" do
      let(:string) { "#{short_flag} #{value}" }

      it "must capture short flag and argument name" do
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
          {
            long_flag: long_flag
          }
        )
      end
    end

    context "when given '--opt VALUE'" do
      let(:string) { "#{long_flag} #{value}" }

      it "must capture the long flag and value" do
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
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
        expect(subject.parse(string)).to eq(
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
    subject { super().option_line }

    let(:short_flag) { '-o'    }
    let(:long_flag)  { '--opt' }
    let(:value)      { 'VALUE' }

    context "when given a line only containing options" do
      let(:line) { "    #{short_flag}, #{long_flag}=#{value}" }

      it "must parse the options" do
        expect(subject.parse(line)).to eq(
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
        expect(subject.parse(line)).to eq(
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
        expect(subject.parse(line)).to eq(
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
        expect(subject.parse(line)).to eq(
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
        expect(subject.parse(line)).to eq(
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
          expect(subject.parse(line)).to eq(
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
          expect(subject.parse(line)).to eq(
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
          expect(subject.parse(line)).to eq(
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
