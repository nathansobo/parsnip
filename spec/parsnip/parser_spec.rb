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

  describe "simple choices" do
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

  describe "assignment of memo entry ranges in the presence of backtracking" do
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

  describe "assignment of ranges on new memo entries when recycling memo entries from a previous parse" do
    let(:grammar) {%{
      grammar
        root = a b
        a = "j" | "k"
        b = c | d
        c = "l" "m" "n"
        d = "l" "m"
      end
    }}

    it "updates the max_position when pulling results from the memo table" do
      parser.parse("jlm").should == true
      parser.retrieve(:root, 0).range.should == (0..3)
      parser.retrieve(:b, 1).range.should == (1..3)
      c = parser.retrieve(:c, 1)
      c.value.should == false
      c.range.should == (1..3)

      parser.update(0..0, 'k') # --> klm

      parser.retrieve(:root, 0).should be_nil
      b = parser.retrieve(:b, 1)
      b.value.should == true
      b.range.should == (1..3)

      parser.parse.should == true

      # max position should be updated when using memoized value of rule b at position 1
      parser.retrieve(:root, 0).range.should == (0..3) 
    end
  end

  describe "updating of the position from a memoized entry when the length of the match differs from the length volatile range" do
    let(:grammar) {%{
      grammar
        root = a b
        a = "l" "m" "n" | "l" "m"
        b = "o" "p" | "o" "q"
      end
    }}


    it "uses the true length of the match instead of the max_position of the volatile range" do
      parser.parse("lmop").should == true
      a = parser.retrieve(:a, 0)
      a.range.should == (0..2)
      a.length.should == 2

      parser.update(3..3, "q") # --> lmoq
      parser.parse.should == true
    end
  end
end

