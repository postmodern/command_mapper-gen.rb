require 'spec_helper'
require 'command_mapper/gen/option_value'

describe CommandMapper::Gen::OptionValue do
  describe "#to_ruby" do
    context "when no keywords are set" do
      it "must return 'true'" do
        expect(subject.to_ruby).to eq("true")
      end
    end

    context "when at least one keyword is set" do
      subject { described_class.new(required: false) }

      it "must return '{...}'" do
        expect(subject.to_ruby).to eq("{required: false}")
      end
    end
  end
end
