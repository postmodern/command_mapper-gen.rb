require 'spec_helper'
require 'command_mapper/gen/command'

describe CommandMapper::Gen::Command do
  let(:command_name) { "foo" }
  let(:parent_command) { described_class.new('bar') }

  subject { described_class.new(command_name) }

  describe "#initialize" do
    it "must set #command_name" do
      expect(subject.command_name).to eq(command_name)
    end

    it "must set #options to {}" do
      expect(subject.options).to eq({})
    end

    it "must set #arguments to {}" do
      expect(subject.arguments).to eq({})
    end

    it "must set #subcommands to {}" do
      expect(subject.subcommands).to eq({})
    end

    context "when a parent command is also given" do
      subject { described_class.new(command_name,parent_command) }

      it "must set #parent_command" do
        expect(subject.parent_command).to be(parent_command)
      end
    end
  end

  describe "#command_string" do
    it "must return the #command_name" do
      expect(subject.command_string).to eq(command_name)
    end

    context "when #parent_command is set" do
      subject { described_class.new(command_name,parent_command) }

      it "must return the #parent_command command_name and the #command_name" do
        expect(subject.command_string).to eq(
          "#{parent_command.command_name} #{command_name}"
        )
      end
    end
  end

  describe "#man_page" do
    it "must return the #command_name" do
      expect(subject.man_page).to eq(command_name)
    end

    context "when #parent_command is set" do
      subject { described_class.new(command_name,parent_command) }

      it "must return the #parent_command command_name and the #command_name" do
        expect(subject.man_page).to eq(
          "#{parent_command.command_name}-#{command_name}"
        )
      end
    end
  end

  describe "#option" do
    let(:flag) { "--option" }
    let(:type) { CommandMapper::Gen::Types::Num.new }
    let(:required) { false }

    before do
      subject.option(flag, value: {required: required, type: type})
    end

    it "must add a new Option to #options with the given flag" do
      expect(subject.options[flag]).to be_kind_of(CommandMapper::Gen::Option)
    end

    it "must pass additional keywords to Option#initialize" do
      expect(subject.options[flag].value.required).to be(required)
      expect(subject.options[flag].value.type).to     be(type)
    end
  end

  describe "#argument" do
    let(:name) { :arg1 }
    let(:required) { false }

    before { subject.argument(name, required: required) }

    it "must add a new Argument to #argument with the given name" do
      expect(subject.arguments[name]).to be_kind_of(CommandMapper::Gen::Argument)
    end

    it "must pass additional keywords to Argument#initialize" do
      expect(subject.arguments[name].required).to be(required)
    end
  end

  describe "#subcommand" do
    let(:name) { :list }

    before { subject.subcommand(name) }

    it "must add a new Command to #subcommands with the given name" do
      expect(subject.subcommands[name]).to be_kind_of(CommandMapper::Gen::Command)
    end
  end

  describe "#class_name" do
    context "when the #command_name is one word" do
      let(:command_name) { "foo" }

      it "must return the captialized version of #command_name" do
        expect(subject.class_name).to eq("Foo")
      end
    end

    context "when the command contains a '_'" do
      let(:command_name) { "foo_bar" }

      it "must return the CamelCased version of #command_name" do
        expect(subject.class_name).to eq("FooBar")
      end
    end

    context "when the command contains a '-'" do
      let(:command_name) { "foo-bar" }

      it "must return the CamelCased version of #command_name" do
        expect(subject.class_name).to eq("FooBar")
      end
    end
  end

  describe "#to_ruby" do
    context "when #parent_command is nil" do
      context "when #command_name is set" do
        it "must print a header, define a class, and define a command block" do
          expect(subject.to_ruby).to start_with(
            [
              "require 'command_mapper/command'",
              "",
              "#",
              "# Represents the `#{subject.command_name}` command",
              "#",
              "class #{subject.class_name} < CommandMapper::Command",
              "",
              "  command #{subject.command_name.inspect} do",
              ''
            ].join($/)
          )
        end

        it "must end the String with 'end ... end'" do
          expect(subject.to_ruby).to end_with(
            [
              '',
              "  end",
              '',
              "end",
              ''
            ].join($/)
          )
        end
      end

      context "when #command_name is nil" do
        let(:command_name) { nil }

        it "must not print the header, class definition, or command block" do
          expect(subject.to_ruby).to_not include(
            "require 'command_mapper/command'"
          )

          expect(subject.to_ruby).to_not include("class")
          expect(subject.to_ruby).to_not include("command ")
        end
      end
    end

    context "when #parent_command is set" do
      subject { described_class.new(command_name,parent_command) }

      it "must print 'subcommand ... do'" do
        expect(subject.to_ruby).to start_with(
          [
            "subcommand #{subject.command_name.inspect} do",
            "end",
            ''
          ].join($/)
        )
      end

      it "must end the String with a single 'end'" do
        expect(subject.to_ruby).to end_with("#{$/}end#{$/}")
      end
    end

    let(:option_flag)     { "--option" }
    let(:option_required) { false      }

    let(:argument_name)     { :arg1 }
    let(:argument_required) { false }

    context "when #options are populated" do
      before do
        subject.option(option_flag, value: {required: option_required})
      end

      it "must print the 'option ...' lines within the command block" do
        expect(subject.to_ruby).to include(
          [
            '',
            "  command #{subject.command_name.inspect} do",
            "    option #{option_flag.inspect}, value: {required: #{option_required.inspect}}",
            "  end",
            ''
          ].join($/)
        )
      end
    end

    context "when #arguments are populated" do
      before do
        subject.argument(argument_name, required: argument_required)
      end

      it "must print the 'argument ...' lines within the command block" do
        expect(subject.to_ruby).to include(
          [
            '',
            "  command #{subject.command_name.inspect} do",
            "    argument #{argument_name.inspect}, required: #{argument_required.inspect}",
            "  end",
            ''
          ].join($/)
        )
      end
    end

    context "when #options and #arguments are both populated" do
      before do
        subject.option(option_flag, value: {required: option_required})
        subject.argument(argument_name, required: argument_required)
      end

      it "must separate the option lines from the argument lines" do
        expect(subject.to_ruby).to include(
          [
            '',
            "  command #{subject.command_name.inspect} do",
            "    option #{option_flag.inspect}, value: {required: #{option_required.inspect}}",
            '',
            "    argument #{argument_name.inspect}, required: #{argument_required.inspect}",
            "  end",
            ''
          ].join($/)
        )
      end
    end

    context "when #subcommands are populated" do
      context "and when there is one subcommand" do
        let(:subcommand_name) { 'baz' }

        before do
          subcommand = subject.subcommand(subcommand_name)

          subcommand.option(option_flag, value: {required: option_required})
          subcommand.argument(argument_name, required: argument_required)
        end

        it "must print the 'subcommand ... do' line within the command block" do
          expect(subject.to_ruby).to include(
            [
              '',
              "  command #{command_name.inspect} do",
              "    subcommand #{subcommand_name.inspect} do",
              "      option #{option_flag.inspect}, value: {required: #{option_required.inspect}}",
              '',
              "      argument #{argument_name.inspect}, required: #{argument_required.inspect}",
              '    end',
              "  end",
              ''
            ].join($/)
          )
        end
      end

      context "and when there is more than one subcommand" do
        let(:subcommand_name1) { "baz" }
        let(:subcommand_name2) { "qux" }

        before do
          subject.subcommand(subcommand_name1)
          subject.subcommand(subcommand_name2)
        end

        it "must separate the 'subcommands ... do' lines" do
          expect(subject.to_ruby).to include(
            [
              '',
              "  command #{command_name.inspect} do",
              "    subcommand #{subcommand_name1.inspect} do",
              "    end",
              '',
              "    subcommand #{subcommand_name2.inspect} do",
              "    end",
              "  end"
            ].join($/)
          )
        end
      end
    end
  end

  describe "#save" do
    let(:path) { '/path/to/file' }

    it "must write #to_ruby to the given file path" do
      expect(File).to receive(:write).with(path,subject.to_ruby)

      subject.save(path)
    end
  end
end
