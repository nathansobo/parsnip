module Parsnip
  class Parser
    extend Forwardable
    def_delegator :memo_table, :retrieve

    attr_reader :grammar, :buffer, :memo_table, :position

    def initialize(grammar)
      @grammar = grammar
    end

    def parse(buffer)
      @buffer = buffer
      @memo_table = MemoTable.new
      @position = 0
      apply(:root)
    end

    def apply(rule_name)
      start_position = position
      value = grammar.apply(rule_name, self)
      memo_table.store(rule_name, start_position, position, value)
      value
    end

    def match_string(string)
      len = string.size
      if buffer[position, len] == string
        advance(len)
        true
      else
        false
      end
    end

    def advance(distance)
      @position += distance
    end

    def rewind(position)
      @position = position
    end
  end
end
