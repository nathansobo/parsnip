require 'spec_helper'

describe "Parser" do
  let(:parser) { Parsnip.from_string(grammar).parser }

  describe "for sequence expressions" do
    let(:grammar) {%{
      grammar
        root = "a" "b" "c"
      end
    }}

    it "accepts matching input" do
      parser.parse('abc').should be_true
    end

    it "rejects non-matching input" do
      parser.parse('abz').should be_false
    end

    it "stores and expires memo entries correctly" do
      parser.parse('abc').should be_true
      memo_entry = parser.retrieve(:root, 0)
      memo_entry.value.should == true
      memo_entry.range.should == (0..3)

      parser.update(2..2, 'z')
      parser.memo_table.should be_empty
      parser.parse.should be_false
      memo_entry = parser.retrieve(:root, 0)
      memo_entry.value.should == false
      memo_entry.range.should == (0..2)
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

    it "accepts matching input" do
      parser.parse('alpha bravo').should be_true
    end

    it "rejects non-matching input" do
      parser.parse('alpha charlie').should be_false
    end

    it "stores and expires memo entries correctly" do
      parser.parse('alpha bravo')
                   #0123456789ab

      root = parser.retrieve(:root, 0)
      root.value.should == true
      root.range.should == (0..11)

      a = parser.retrieve(:a, 0)
      a.value.should == true
      a.range.should == (0..5)

      b = parser.retrieve(:b, 6)
      b.value.should == true
      b.range.should == (6..11)

      parser.update(9..9, 'nd') # alpha brando

      # keep a, it wasn't disturbed
      a = parser.retrieve(:a, 0)
      a.value.should == true
      a.range.should == (0..5)

      # discard root and b
      parser.retrieve(:root, 0).should be_nil
      parser.retrieve(:b, 6).should be_nil

      parser.parse.should be_false
      parser.retrieve(:b, 6).value.should be_false
    end
  end
end

