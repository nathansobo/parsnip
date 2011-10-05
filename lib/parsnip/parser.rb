module Parsnip
  class Parser
    extend Forwardable
    def_delegator :memo_table, :retrieve

    attr_reader :grammar, :buffer, :memo_table, :position, :max_position_stack

    def initialize(grammar)
      @grammar = grammar
    end

    def parse(buffer=nil)
      if buffer
        @buffer = buffer
        @memo_table = MemoTable.new
      end
      @position = 0
      @max_position_stack = [0]
      apply(:root)
    end

    def update(range, new_string)
      buffer[range] = new_string
      memo_table.expire(range, new_string.length)
    end

    def apply(rule_name)
      if memo_entry = memo_table.retrieve(rule_name, position)
        advance_position(memo_entry.length)
        memo_entry.value
      else
        start_position = position
        push_max_position
        value = grammar.apply(rule_name, self)
        memo_table.store(rule_name, start_position, max_position, value)
        pop_max_position
        value
      end
    end

    def match_string(string)
      len = string.size
      advance_max_position(len - 1)
      if buffer[position, len] == string
        advance_position(len)
        true
      else
        false
      end
    end

    def advance_position(distance)
      @position += distance
    end

    def advance_max_position(distance)
      new_max = position + distance
      max_position_stack[-1] = new_max if new_max > max_position
    end

    def max_position
      max_position_stack.last
    end

    def push_max_position
      max_position_stack.push(position)
    end

    def pop_max_position
      previous_max = max_position_stack.pop
      max_position_stack[-1] = previous_max if previous_max > max_position
    end

    def rewind(position)
      @position = position
    end
  end
end
