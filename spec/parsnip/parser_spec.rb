require 'spec_helper'

describe "Parser" do
  describe "for sequence expressions" do
    let(:parser) { Parsnip.from_string(grammar).parser }

    let(:grammar) {%{
      grammar
        root = "a" "b" "c"
      end
    }}

    it "parses matching input successfully" do
      parser.parse('abc').should be_true
    end
  end
end

