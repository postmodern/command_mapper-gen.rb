require 'spec_helper'
require 'command_mapper/gen/argument'
require 'command_mapper/gen/types/value'

describe CommandMapper::Gen::Argument do
  let(:name) { :arg1 }

  subject { described_class.new(name) }

  describe "#initialize" do
    it "must set #name" do
      expect(subject.name).to eq(name)
    end

    it "must default #value to nil" do
      expect(subject.value).to be(nil)
    end

    it "must default #repeats to nil" do
      expect(subject.repeats).to be(nil)
    end

    context "when given the value: keyword argument" do
      context "and it's a Type::Value object" do
        let(:value) { Types::Value.new(required: true) }

        subject { described_class.new(name, value: value) }

        it "must set #value" do
          expect(subject.value).to be(value)
        end
      end

      context "and it's a Hash" do
        subject { described_class.new(name, value: {required: true}) }

        it "must initialize #value as a Types::Value object" do
          expect(subject.value).to be_kind_of(Types::Value)
          expect(subject.value.required).to be(true)
        end
      end
    end

    context "when given the repeats: keyword argument" do
      let(:repeats) { true }

      subject { described_class.new(name, repeats: repeats) }

      it "must set #repeats" do
        expect(subject.repeats).to eq(repeats)
      end
    end
  end

  describe "#to_ruby" do
    it "must output 'argument \#{name}'" do
      expect(subject.to_ruby).to eq("argument #{name.inspect}")
    end

    context "when #value is not nil" do
      let(:value) { Types::Value.new(required: true) }

      subject { described_class.new(name, value: value) }

      it "must append 'value: ...' and call the #value's #to_ruby method" do
        expect(subject.to_ruby).to eq("argument #{name.inspect}, value: #{value.to_ruby}")
      end
    end

    context "when #repeats is true" do
      let(:repeats) { true }

      subject { described_class.new(name, repeats: repeats) }

      it "must append 'repeats: true'" do
        expect(subject.to_ruby).to eq("argument #{name.inspect}, repeats: #{repeats.inspect}")
      end
    end
  end
end
