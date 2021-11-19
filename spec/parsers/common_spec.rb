require 'spec_helper'
require 'command_mapper/gen/parsers/common'

describe CommandMapper::Gen::Parsers::Common do
  describe "#space" do
    subject { super().space }

    context "when given a ' '" do
      let(:string) { ' ' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given multiple spaces" do
      let(:string) { '   ' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given a non-space character" do
      let(:string) { 'A' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#spaces" do
    subject { super().spaces }

    context "when given an empty string" do
      let(:string) { '' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given one space" do
      let(:string) { ' ' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given multiple spaces" do
      let(:string) { '   ' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end
  end

  describe "#space?" do
    subject { super().space? }

    context "when given an empty string" do
      let(:string) { '' }

      it "must not parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given one space" do
      let(:string) { ' ' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given multiple spaces" do
      let(:string) { '   ' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#ellipsis" do
    subject { super().ellipsis }

    context "when given '...'" do
      let(:string) { '...' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end
  end

  describe "#ellipsis?" do
    subject { super().ellipsis? }

    context "when given an empty string" do
      let(:string) { '' }

      it "must not parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given '...'" do
      let(:string) { '...' }

      it "must parse it" do
        expect(subject.parse(string)).to eq({repeats: string})
      end
    end

    context "when given ' ...'" do
      let(:string) { ' ...' }

      it "must parse the '...'" do
        expect(subject.parse(string)).to eq({repeats: string.strip})
      end
    end
  end

  describe "#capitalized_name" do
    subject { super().capitalized_name }

    context "when given a single lowercase character" do
      let(:string) { 'a' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given a '-' character" do
      let(:string) { '-' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given a '_' character" do
      let(:string) { '_' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given one uppercase character" do
      let(:string) { 'A' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given one uppercase character and a lowercase character" do
      let(:string) { 'Ab' }

      it "must not parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given one uppercase character followed by multiple lowercase characters" do
      let(:string) { 'Abbbb' }

      it "must not parse it" do
        expect(subject.parse(string)).to eq(string)
      end

      context "and it contains a '_' character" do
        let(:string) { 'Abb_bb' }

        it "must parse it" do
          expect(subject.parse(string)).to eq(string)
        end
      end

      context "and it contains a '-' character" do
        let(:string) { 'Abb-bb' }

        it "must parse it" do
          expect(subject.parse(string)).to eq(string)
        end
      end
    end

    context "when given two uppercase characters" do
      let(:string) { 'AB' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#lowercase_name" do
    subject { super().lowercase_name }

    context "when given a '_' character" do
      let(:string) { '_' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given one lowercase character" do
      let(:string) { 'a' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given multiple lowercase characters" do
      let(:string) { 'ab' }

      it "must parse it" do
        expect(subject.parse(string)).to eq(string)
      end
 
      context "and it contains a '_' character" do
        let(:string) { 'abb_bb' }

        it "must parse it" do
          expect(subject.parse(string)).to eq(string)
        end
      end
 
      context "and it contains a '-' character" do
        let(:string) { 'abb-bb' }

        it "must parse it" do
          expect(subject.parse(string)).to eq(string)
        end
      end
    end

    context "when given a single uppercase characters" do
      let(:string) { 'A' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when it contains a uppercase character" do
      let(:string) { 'aaaaBaaaa' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#uppercase_name" do
    subject { super().uppercase_name }

    context "when given a '_' character" do
      let(:string) { '_' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given one uppercase character" do
      let(:string) { 'A' }

      it "must not parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given multiple uppercase characters" do
      let(:string) { 'AB' }

      it "must not parse it" do
        expect(subject.parse(string)).to eq(string)
      end

      context "and it contains a '_' character" do
        let(:string) { 'ABB_BB' }

        it "must not parse it" do
          expect(subject.parse(string)).to eq(string)
        end
      end

      context "and it contains a '-' character" do
        let(:string) { 'ABB-BB' }

        it "must not parse it" do
          expect(subject.parse(string)).to eq(string)
        end
      end
    end

    context "when given a single lowercase characters" do
      let(:string) { 'a' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when it contains a uppercase character" do
      let(:string) { 'AAAAbAAAA' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#short_flag" do
    subject { super().short_flag }

    context "when given a single '-'" do
      let(:string) { '-' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given a '-' and a lowercase alphabetic character" do
      let(:string) { '-a' }

      it "must not parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given a '-' and a uppercase alphabetic character" do
      let(:string) { '-A' }

      it "must not parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given a '-' and a numeric character" do
      let(:string) { '-0' }

      it "must not parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given a '-' and a '#' character" do
      let(:string) { '-#' }

      it "must not parse it" do
        expect(subject.parse(string)).to eq(string)
      end
    end

    context "when given '--'" do
      let(:string) { '--' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given '-_'" do
      let(:string) { '-_' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "#long_flag" do
    subject { super().long_flag }

    context "when given a '--'" do
      let(:string) { '-' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given a '--' and a lowercase alphabetic character" do
      let(:string) { '--a' }

      it "must parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given a '--' and a uppercase alphabetic character" do
      let(:string) { '--A' }

      it "must parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given a '--' and a numeric character" do
      let(:string) { '--0' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given a '---'" do
      let(:string) { '---' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when given a '--' and an underscore" do
      let(:string) { '--_' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when the string contains repeating '-' characters" do
      let(:string) { '--foo--bar' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end

    context "when the string contains repeating '_' characters" do
      let(:string) { '--foo__bar' }

      it "must not parse it" do
        expect { subject.parse(string) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end
end
