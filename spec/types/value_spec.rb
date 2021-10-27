require 'spec_helper'
require 'command_mapper/gen/types/value'

describe CommandMapper::Gen::Types::Value do
  describe "#initialize" do
    it "must default #required to nil" do
      expect(subject.required).to be(nil)
    end

    it "must default #allow_empty to nil" do
      expect(subject.allow_empty).to be(nil)
    end

    it "must default #allow_blank to nil" do
      expect(subject.allow_blank).to be(nil)
    end

    context "when the required: keyword is given" do
      let(:required) { true }

      subject { described_class.new(required: required) }

      it "must set #required" do
        expect(subject.required).to be(required)
      end
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

  describe "#to_ruby_keywords" do
    context "when none of the keywords are set" do
      subject { described_class.new }

      it "must return nil" do
        expect(subject.to_ruby_keywords).to be(nil)
      end
    end

    context "when only one keyword is set" do
      let(:keyword) { :allow_empty }
      let(:value)   { true }

      subject { described_class.new(**{keyword => value}) }

      it "must return only that one keyword and it's value" do
        expect(subject.to_ruby_keywords).to eq("#{keyword}: #{value.inspect}")
      end
    end

    context "when more than one keyword is set" do
      let(:keyword1) { :required }
      let(:value1)   { true }
      let(:keyword2) { :allow_empty }
      let(:value2)   { true }

      subject do
        described_class.new(**{keyword1 => value1, keyword2 => value2})
      end

      it "must return the set keyword and their values" do
        expect(subject.to_ruby_keywords).to eq(
          "#{keyword1}: #{value1.inspect}, #{keyword2}: #{value2.inspect}"
        )
      end
    end

    context "when all keywords are set" do
      let(:keyword1) { :required }
      let(:value1)   { true }
      let(:keyword2) { :allow_empty }
      let(:value2)   { true }
      let(:keyword3) { :allow_blank }
      let(:value3)   { true }

      subject do
        described_class.new(**{
          keyword1 => value1,
          keyword2 => value2,
          keyword3 => value3
        })
      end

      it "must return all set keywords and their values" do
        expect(subject.to_ruby_keywords).to eq(
          "#{keyword1}: #{value1.inspect}, #{keyword2}: #{value2.inspect}, #{keyword3}: #{value3.inspect}"
        )
      end
    end
  end

  describe "#to_ruby" do
    context "when only #required is set" do
      context "and it's true" do
        subject { described_class.new(required: true) }

        it "must return ':required'" do
          expect(subject.to_ruby).to eq(":required")
        end
      end

      context "and it's false" do
        subject { described_class.new(required: false) }

        it "must return ':optional'" do
          expect(subject.to_ruby).to eq(":optional")
        end
      end
    end

    context "when more than just required is set" do
      let(:keyword1) { :required }
      let(:value1)   { true }
      let(:keyword2) { :allow_empty }
      let(:value2)   { true }
      let(:keyword3) { :allow_blank }
      let(:value3)   { true }

      subject do
        described_class.new(**{
          keyword1 => value1,
          keyword2 => value2,
          keyword3 => value3
        })
      end

      it "must output {...} containing the ruby keyword" do
        expect(subject.to_ruby).to eq(
          "{#{keyword1}: #{value1.inspect}, #{keyword2}: #{value2.inspect}, #{keyword3}: #{value3.inspect}}"
        )
      end
    end
  end
end
