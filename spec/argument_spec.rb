require 'spec_helper'
require 'command_mapper/gen/argument'
require 'command_mapper/gen/types/str'
require 'command_mapper/gen/types/num'

describe CommandMapper::Gen::Argument do
  let(:name) { :arg1 }

  subject { described_class.new(name) }

  describe "#initialize" do
    it "must set #name" do
      expect(subject.name).to eq(name)
    end

    it "must default #type to nil" do
      expect(subject.type).to be(nil)
    end

    it "must default #repeats to nil" do
      expect(subject.repeats).to be(nil)
    end

    context "when given the value: keyword argument" do
      context "and it's a Types object" do
        let(:type) { Types::Num.new }

        subject { described_class.new(name, type: type) }

        it "must set #type" do
          expect(subject.type).to be(type)
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

    context "when #required is true" do
      let(:required) { true}

      subject { described_class.new(name, required: required) }

      it "must not append 'required: true'" do
        expect(subject.to_ruby).to eq("argument #{name.inspect}")
      end
    end

    context "when #required is false" do
      let(:required) { false }

      subject { described_class.new(name, required: required) }

      it "must append 'required: false'" do
        expect(subject.to_ruby).to eq("argument #{name.inspect}, required: #{required.inspect}")
      end
    end

    context "when #type is not nil" do
      let(:type) { Types::Num.new }

      subject { described_class.new(name, type: type) }

      it "must append 'type: ...' and call the #type's #to_ruby method" do
        expect(subject.to_ruby).to eq("argument #{name.inspect}, type: #{type.to_ruby}")
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
