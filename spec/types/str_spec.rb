require 'spec_helper'
require 'command_mapper/gen/types/str'

describe CommandMapper::Gen::Types::Str do
  describe "#initialize" do
    it "must default #allow_empty to nil" do
      expect(subject.allow_empty).to be(nil)
    end

    it "must default #allow_blank to nil" do
      expect(subject.allow_blank).to be(nil)
    end

    context "when the allow_empty: keyword is given" do
      let(:allow_empty) { true }

      subject { described_class.new(allow_empty: allow_empty) }

      it "must set #allow_empty" do
        expect(subject.allow_empty).to be(allow_empty)
      end
    end

    context "when the allow_blank: keyword is given" do
      let(:allow_blank) { true }

      subject { described_class.new(allow_blank: allow_blank) }

      it "must set #allow_blank" do
        expect(subject.allow_blank).to be(allow_blank)
      end
    end
  end

  describe "#to_ruby" do
    context "when none of the keywords are set" do
      subject { described_class.new }

      it "must return nil" do
        expect(subject.to_ruby).to be(nil)
      end
    end

    context "when only one keyword is set" do
      let(:keyword) { :allow_empty }
      let(:value)   { true }

      subject { described_class.new(**{keyword => value}) }

      it "must return only that one keyword and it's value" do
        expect(subject.to_ruby).to eq("#{keyword}: #{value.inspect}")
      end
    end

    context "when more than one keyword is set" do
      let(:allow_empty) { true }
      let(:allow_blank) { true }

      subject do
        described_class.new(allow_empty: allow_empty, allow_blank: allow_blank)
      end

      it "must return the set keyword and their values" do
        expect(subject.to_ruby).to eq(
          "allow_empty: #{allow_empty.inspect}, allow_blank: #{allow_blank.inspect}"
        )
      end
    end
  end
end
