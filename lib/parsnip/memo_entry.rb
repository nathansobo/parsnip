module Parsnip
  class MemoEntry
    def initialize(attributes)
      @attributes = attributes
    end

    def rule_name
      @attributes[:rule_name]
    end

    def begins_at
      @attributes[:begins_at]
    end

    def ends_at
      @attributes[:ends_at]
    end

    def value
      @attributes[:value]
    end

    def range
      begins_at..ends_at
    end
  end
end
