require 'spec_helper'
require 'command_mapper/gen/task'

describe CommandMapper::Gen::Task do
  let(:command_name) { 'grep' }
  let(:output) { '/path/to/output.rb' }

  subject { described_class.new(command_name,output) }

  describe "#initialize" do
    it "must set #command_name" do
      expect(subject.command_name).to eq(command_name)
    end

    it "must set #output" do
      expect(subject.output).to eq(output)
    end

    context "when the parser: keyword argument is given" do
      let(:parser) { :man }

      subject { described_class.new(command_name,output, parser: parser) }

      it "must set #parser" do
        expect(subject.parser).to eq(parser)
      end
    end

    context "when a block is given" do
      it "must yield the new task and then call #define" do
        yielded_task = nil

        described_class.new(command_name,output) do |task|
          yielded_task = task

          expect(task).to receive(:define)
        end

        expect(yielded_task).to be_kind_of(described_class)
      end
    end
  end

  describe "#generate" do
    it "must call `sh('command_mapper-gen','--output',output,command_name)`" do
      expect(subject).to receive(:sh).with(
        'command_mapper-gen', '--output', output, command_name
      )

      subject.generate
    end

    context "when #parser is set" do
      let(:parser) { :man }

      subject { described_class.new(command_name,output, parser: parser) }

      it "must call `sh('command_mapper-gen','--output',output,'--parser',parser,command_name)`" do
        expect(subject).to receive(:sh).with(
          'command_mapper-gen', '--output', output,
                                '--parser', parser.to_s,
                                command_name
        )

        subject.generate
      end
    end
  end
end
