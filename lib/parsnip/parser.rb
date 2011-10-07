module Parsnip
  class Parser
    attr_reader :grammar, :buffer, :memo_table, :position, :max_position_stack

    def initialize(grammar)
      @grammar = grammar
    end

    def parse(buffer=nil)
      @buffer = buffer if buffer
      @position = 0
      @max_position_stack = [0]
      apply(:root)
    end

    def update(range, new_string)
      buffer[range] = new_string
      MemoEntry.expire(range, new_string.length)
    end

    def retrieve(rule_name, position)
      MemoEntry[:rule_name => rule_name.to_s, :min_position => position]
    end

    def apply(rule_name)
      if memo_entry = retrieve(rule_name, position)
        advance_position(memo_entry.length)
        update_max_position(memo_entry.max_position)
        if memo_entry.value.instance_of?(LeftRecursion)
          memo_entry.value.detected!
          false
        else
          memo_entry.value
        end
      else
        left_recursion = LeftRecursion.new
        memo_entry = MemoEntry.create(
          :rule_name => rule_name,
          :min_position => position,
          :value => left_recursion
        )

        start_position = position
        push_max_position

        value = grammar.apply(rule_name, self)

        memo_entry.update(
          :max_position => max_position,
          :length => position - start_position,
          :value => value
        )

        pop_max_position

        if left_recursion.detected?
          grow_left_recursion(rule_name, position, memo_entry, nil)
        else
          value
        end
      end
    end

    def grow_left_recursion(*args)
      false
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

    class LeftRecursion
      def initialize
        @detected = false
      end

      def detected!
        @detected = true
      end

      def detected?
        @detected
      end
    end
  end
end
