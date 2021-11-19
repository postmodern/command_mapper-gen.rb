require 'spec_helper'
require 'command_mapper/gen/cli'

describe CommandMapper::Gen::CLI do
  describe "#initialize" do
    it "must default #output to nil" do
      expect(subject.output).to be(nil)
    end

    it "must default #parsers to [Parsers::Help, Parsers::Man]" do
      expect(subject.parsers).to eq([Parsers::Help, Parsers::Man])
    end

    it "must default #command to nil" do
      expect(subject.command).to be(nil)
    end

    it "must initialize #option_parser" do
      expect(subject.option_parser).to be_kind_of(OptionParser)
    end
  end

  describe ".run" do
    subject { described_class }

    context "when Interrupt is raised" do
      before do
        expect_any_instance_of(described_class).to receive(:run).and_raise(Interrupt)
      end

      it "must exit with 130" do
        expect(subject.run([])).to eq(130)
      end
    end

    context "when Errno::EPIPE is raised" do
      before do
        expect_any_instance_of(described_class).to receive(:run).and_raise(Errno::EPIPE)
      end

      it "must exit with 0" do
        expect(subject.run([])).to eq(0)
      end
    end
  end

  describe "#run" do
    let(:command_name) { 'yes' }

    let(:expected_output) do
      [
        "require 'command_mapper/command'",
        "",
        "#",
        "# Represents the `#{command_name}` command",
        "#",
        "class #{command_name.capitalize} < CommandMapper::Command",
        "",
        "  command \"#{command_name}\" do",
        "    option \"--help\"",
        "    option \"--version\"",
        "",
        "    argument :string, required: false",
        "  end",
        "",
        "end",
      ].join($/) + $/
    end

    context "when given a COMMAND_NAME" do
      let(:argv) { [command_name] }

      it "must parse the command's --help and/or man page and print ruby code" do
        expect {
          subject.run(argv)
        }.to output(expected_output).to_stdout
      end

      context "but the command isn't installed" do
        before do
          allow(CommandMapper::Gen::Parsers::Help).to receive(:`).with("#{command_name} --help 2>&1").and_raise(Errno::ENOENT.new(command_name))
        end

        it "must print an error and exit with -1" do
          expect {
            expect(subject.run(argv)).to eq(-1)
          }.to output("#{described_class::PROGRAM_NAME}: command #{command_name.inspect} is not installed#{$/}").to_stderr
        end
      end
    end

    context "when an invalid option is given" do
      let(:option) { "--foo"  }
      let(:argv)   { [option] }

      it "must print an error message and return -1" do
        expect {
          expect(subject.run(argv)).to eq(-1)
        }.to output("#{described_class::PROGRAM_NAME}: invalid option: #{option}#{$/}").to_stderr
      end
    end

    context "when the command's --help and -h output are empty" do
      let(:argv) { %w[true] }

      it "must print an error message and return -2" do
        expect {
          expect(subject.run(argv)).to eq(-2)
        }.to output("#{described_class::PROGRAM_NAME}: no options or arguments detected#{$/}").to_stderr
      end
    end

    context "when no arguments are given" do
      let(:argv) { [] }

      it "must print an error message and return -1" do
        expect {
          expect(subject.run(argv)).to eq(-1)
        }.to output("#{described_class::PROGRAM_NAME}: expects a COMMAND_NAME#{$/}").to_stderr
      end
    end
  end

  describe "#option_parser" do
    context "when given -o FILE" do
      let(:file) { "/path/to/file.rb" }
      let(:argv) { ['-o', file] }

      before { subject.option_parser.parse(argv) }

      it "must set #output to the FILE" do
        expect(subject.output).to eq(file)
      end
    end

    context "when given --output FILE" do
      let(:file) { "/path/to/file.rb" }
      let(:argv) { ['--output', file] }

      before { subject.option_parser.parse(argv) }

      it "must set #output to the FILE" do
        expect(subject.output).to eq(file)
      end
    end

    context "when givne -p help" do
      let(:argv) { ['-p', "help"] }

      before { subject.option_parser.parse(argv) }

      it "must set #parsers to [Parser::Help]" do
        expect(subject.parsers).to eq([Parsers::Help])
      end
    end

    context "when givne -p man" do
      let(:argv) { ['-p', "man"] }

      before { subject.option_parser.parse(argv) }

      it "must set #parsers to [Parser::Man]" do
        expect(subject.parsers).to eq([Parsers::Man])
      end
    end

    context "when givne --parser help" do
      let(:argv) { ['--parser', "help"] }

      before { subject.option_parser.parse(argv) }

      it "must set #parsers to [Parser::Help]" do
        expect(subject.parsers).to eq([Parsers::Help])
      end
    end

    context "when givne --parser man" do
      let(:argv) { ['--parser', "man"] }

      before { subject.option_parser.parse(argv) }

      it "must set #parsers to [Parser::Man]" do
        expect(subject.parsers).to eq([Parsers::Man])
      end
    end

    context "when given -V" do
      let(:argv) { ["-v"] }

      it "must print the command name and version, then exit" do
        expect(subject).to receive(:exit)

        expect {
          subject.option_parser.parse(argv)
        }.to output("#{described_class::PROGRAM_NAME} #{VERSION}#{$/}").to_stdout
      end
    end

    context "when given --version" do
      let(:argv) { ["--version"] }

      it "must print the command name and version, then exit" do
        expect(subject).to receive(:exit)

        expect {
          subject.option_parser.parse(argv)
        }.to output("#{described_class::PROGRAM_NAME} #{VERSION}#{$/}").to_stdout
      end
    end

    context "when given -h" do
      let(:argv) { ["-h"] }

      it "must print help text and then exit" do
        expect(subject).to receive(:exit)

        expect {
          subject.option_parser.parse(argv)
        }.to output("#{subject.option_parser}").to_stdout
      end
    end

    context "when given --help" do
      let(:argv) { ["-h"] }

      it "must print help text and then exit" do
        expect(subject).to receive(:exit)

        expect {
          subject.option_parser.parse(argv)
        }.to output("#{subject.option_parser}").to_stdout
      end
    end
  end

  describe "#print_error" do
    let(:message) { "error!" }

    it "must print the command name and the message to stderr" do
      expect {
        subject.print_error(message)
      }.to output("#{described_class::PROGRAM_NAME}: #{message}#{$/}").to_stderr
    end
  end
end
