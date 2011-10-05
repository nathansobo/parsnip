module Parsnip
  class Parser
    extend Forwardable
    def_delegator :memo_table, :retrieve

    attr_reader :grammar, :buffer, :memo_table, :position, :max_position

    def initialize(grammar)
      @grammar = grammar
    end

    def parse(buffer=nil)
      if buffer
        @buffer = buffer
        @memo_table = MemoTable.new
      end
      @position = 0
      @max_position = 0
      apply(:root)
    end

    def update(range, new_string)
      buffer[range] = new_string
      memo_table.expire(range, new_string.length)
    end

    def apply(rule_name)
      start_position = position
      value = grammar.apply(rule_name, self)
      memo_table.store(rule_name, start_position, max_position, value)
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
      set_max_position
    end

    def rewind(position)
      set_max_position
      @position = position
    end

    def set_max_position
      if position > max_position
        @max_position = position
      end
    end
  end
end
