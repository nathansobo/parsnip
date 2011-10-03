module Parsnip
  class Parser
    attr_reader :pos, :grammar

    def initialize(grammar)
      @grammar = grammar
    end

    def parse(buffer)
      @buffer = buffer
      @pos = 0
      apply(:root)
    end

    def apply(rule_name)
      @grammar.apply(rule_name, self)
    end

    def match_string(string)
      len = string.size
      if @buffer[pos, len] == string
        advance(len)
        true
      else
        false
      end
    end

    def advance(distance)
      @pos += distance
    end

    def rewind(pos)
      @pos = pos
    end
  end
end
