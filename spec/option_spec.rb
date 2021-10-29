require 'spec_helper'
require 'command_mapper/gen/option'
require 'command_mapper/gen/types/num'

describe CommandMapper::Gen::Option do
  let(:flag) { '--op1' }

  subject { described_class.new(flag) }

  describe "#initialize" do
    it "must set #flag" do
      expect(subject.flag).to eq(flag)
    end

    it "must default #equals to nil" do
      expect(subject.equals).to be(nil)
    end

    it "must default #repeats to nil" do
      expect(subject.repeats).to be(nil)
    end

    it "must default #value to nil" do
      expect(subject.value).to be(nil)
    end

    context "when given the value: keyword argument" do
      context "and it's a Types object" do
        let(:value) { {type: Types::Num.new} }

        subject { described_class.new(flag, value: value) }

        it "must initialize #value as an OptionValue object" do
          expect(subject.value).to be_kind_of(OptionValue)
        end
      end
    end

    context "when given the repeats: keyword argument" do
      let(:repeats) { true }

      subject { described_class.new(flag, repeats: repeats) }

      it "must set #repeats" do
        expect(subject.repeats).to eq(repeats)
      end
    end
  end

  describe "#to_ruby" do
    it "must output 'option \#{flag}'" do
      expect(subject.to_ruby).to eq("option #{flag.inspect}")
    end

    context "when #equals is true" do
      let(:equals) { true }

      subject { described_class.new(flag, equals: equals) }

      it "must append 'equals: true'" do
        expect(subject.to_ruby).to eq("option #{flag.inspect}, equals: #{equals.inspect}")
      end
    end

    context "when #repeats is true" do
      let(:repeats) { true }

      subject { described_class.new(flag, repeats: repeats) }

      it "must append 'repeats: true'" do
        expect(subject.to_ruby).to eq("option #{flag.inspect}, repeats: #{repeats.inspect}")
      end
    end

    context "when #type is not nil" do
      let(:value) { {required: true} }

      subject { described_class.new(flag, value: value) }

      it "must append 'value: ...' and call the #value's #to_ruby method" do
        expect(subject.to_ruby).to eq("option #{flag.inspect}, value: #{subject.value.to_ruby}")
      end
    end
  end
end
