require 'spec_helper'
require 'command_mapper/gen/types/enum'

describe CommandMapper::Gen::Types::Enum do
  let(:values) do
    [:foo, :bar, :baz]
  end

  subject { described_class.new(values) }

  describe "#initialize" do
    it "must set #values" do
      expect(subject.values).to eq(values)
    end
  end

  describe "#to_ruby" do
    context "when #map only has one value" do
      let(:value) { :foo }
      let(:values) do
        [value]
      end

      it "must return 'Enum[value]'" do
        expect(subject.to_ruby).to eq(
          "Enum[#{value.inspect}]"
        )
      end
    end

    context "when #map has more than one key:value pair" do
      let(:value1) { "foo" }
      let(:value2) { "bar" }
      let(:values) do
        [value1, value2]
      end

      it "must return 'Enum[value, ...]'" do
        expect(subject.to_ruby).to eq(
          "Enum[#{value1.inspect}, #{value2.inspect}]"
        )
      end
    end
  end
end
