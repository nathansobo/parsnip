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
        advance_position(memo_entry.length) # TODO: Calculating the length from the max position, but this may not be the real length of the node!
        update_max_position(memo_entry.max_position)
        memo_entry.value
      else
        min_position = position
        push_max_position
        value = grammar.apply(rule_name, self)
        memo_table.store(
          :rule_name => rule_name,
          :min_position => min_position,
          :max_position => max_position,
          :length => position - min_position,
          :value => value
        )
        pop_max_position
        value
      end
    end

    def match_string(string)
      len = string.size
      update_max_position(position + len - 1)
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

    def update_max_position(new_max)
      max_position_stack[-1] = new_max if new_max > max_position
    end

    def max_position
      max_position_stack.last
    end

    def push_max_position
      max_position_stack.push(position)
    end

    def pop_max_position
      update_max_position(max_position_stack.pop)
    end

    def rewind(position)
      @position = position
    end
  end
end
