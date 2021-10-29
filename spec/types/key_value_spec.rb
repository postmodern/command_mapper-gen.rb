require 'spec_helper'
require 'command_mapper/gen/types/key_value'

describe CommandMapper::Gen::Types::KeyValue do
  describe "#initialize" do
    it "must default #separator to '='" do
      expect(subject.separator).to eq('=')
    end

    context "when initialized with the separator: keyword argument" do
      let(:separator) { ':' }

      subject { described_class.new(separator: separator) }

      it "must set #separator" do
        expect(subject.separator).to eq(separator)
      end
    end
  end

  describe "#to_ruby" do
    it "must return 'KeyValue.new()'" do
      expect(subject.to_ruby).to eq("KeyValue.new()")
    end

    context "when #separator is not '='" do
      let(:separator) { ':' }

      subject { described_class.new(separator: separator) }

      it "must return 'KeyValue.new(separator: ...)'" do
        expect(subject.to_ruby).to eq("KeyValue.new(separator: #{separator.inspect})")
      end
    end
  end
end
