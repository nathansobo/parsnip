require 'spec_helper'

describe "Parser" do
  let(:parser) { Parsnip.from_string(grammar).parser }

  describe "with sequence expressions" do
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
      memo_entry.range.should == (0..2)

      parser.update(2..2, 'z')
      parser.memo_table.should be_empty
      parser.parse.should be_false
      memo_entry = parser.retrieve(:root, 0)
      memo_entry.value.should == false
      memo_entry.range.should == (0..2)
    end
  end

  describe "with rule references" do
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
      root.range.should == (0..10)

      a = parser.retrieve(:a, 0)
      a.value.should == true
      a.range.should == (0..4)

      b = parser.retrieve(:b, 6)
      b.value.should == true
      b.range.should == (6..10)

      parser.update(9..9, 'nd') # alpha brando
                                # 0123456789abc

      # keep a, it wasn't disturbed
      a = parser.retrieve(:a, 0)
      a.value.should == true
      a.range.should == (0..4)

      # discard root and b
      parser.retrieve(:root, 0).should be_nil
      parser.retrieve(:b, 6).should be_nil

      parser.parse.should be_false
      new_b = parser.retrieve(:b, 6)
      new_b.value.should be_false
      new_b.range.should == (6..10)
    end
  end

  describe "with choices" do
    let(:grammar) {%{
      grammar
        root = a | b | "zulu"
        a = "alpha"
        b = "bravo"
      end
    }}

    it "accepts matching input" do
      parser.parse('alpha').should == true
      parser.parse('bravo').should == true
      parser.parse('zulu').should == true
    end

    it "rejects non-matching input" do
      parser.parse('charlie').should == false
    end
  end

  describe "with choices that force a backtrack" do
    let(:grammar) {%{
      grammar
        root = a | b
        a = "a" "b" "c"
        b = "a" "b"
      end
    }}

    it "records a memo entry with ends_at including the position where the backtrack was triggered" do
      parser.parse("ab").should be_true
      root = parser.retrieve(:root, 0)
      root.value.should == true
      root.range.should == (0..2)

      a = parser.retrieve(:a, 0)
      a.value.should == false
      a.range.should == (0..2)

      b = parser.retrieve(:b, 0)
      b.value.should == true
      b.range.should == (0..1)
    end
  end
end

