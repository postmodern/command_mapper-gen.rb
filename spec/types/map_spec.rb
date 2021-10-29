require 'spec_helper'
require 'command_mapper/gen/types/map'

describe CommandMapper::Gen::Types::Map do
  let(:map) do
    {:foo => "foo", :bar => "bar"}
  end

  subject { described_class.new(map) }

  describe "#initialize" do
    it "must set #map" do
      expect(subject.map).to eq(map)
    end
  end

  describe "#to_ruby" do
    context "when #map only has one key:value pair" do
      let(:key)   { :foo }
      let(:value) { "foo" }
      let(:map) do
        {key => value}
      end

      it "must return 'Map.new(key => value)'" do
        expect(subject.to_ruby).to eq(
          "Map.new(#{key.inspect} => #{value.inspect})"
        )
      end
    end

    context "when #map has more than one key:value pair" do
      let(:key1)   { :foo }
      let(:value1) { "foo" }
      let(:key2)   { :bar }
      let(:value2) { "bar" }
      let(:map) do
        {key1 => value1, key2 => value2}
      end

      it "must return 'Map.new(key => value, ...)'" do
        expect(subject.to_ruby).to eq(
          "Map.new(#{key1.inspect} => #{value1.inspect}, #{key2.inspect} => #{value2.inspect})"
        )
      end
    end
  end
end
