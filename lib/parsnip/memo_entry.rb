module Parsnip
  class MemoEntry
    def initialize(attributes)
      @attributes = attributes
    end

    def rule_name
      @attributes[:rule_name]
    end

    def min_position
      @attributes[:min_position]
    end

    def max_position
      @attributes[:max_position]
    end

    def length
      @attributes[:length]
    end

    def value
      @attributes[:value]
    end

    def range
      min_position..max_position
    end
  end
end
