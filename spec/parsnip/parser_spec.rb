require 'spec_helper'

describe "Parser" do
  let(:parser) { Parsnip.from_string(grammar).parser }

  describe "sequence expressions" do
    let(:grammar) {%{
      grammar
        root = "a" "b" "c"
      end
    }}

    it "accepts matching input" do
      parser.parse('abc').should be_true
      memo_entry = parser.retrieve(:root, 0)
      memo_entry.value.should == true
      memo_entry.range.should == (0..3)
    end

    it "rejects non-matching input" do
      parser.parse('abz').should be_false
    end
  end

  describe "rule references" do
    let(:grammar) {%{
      grammar
        root = a " " b
        a = "alpha"
        b = "bravo"
      end
    }}

    it "parses matching input successfully" do
      parser.parse('alpha bravo').should be_true
      parser.parse('alpha charlie').should be_false
    end
  end
end

