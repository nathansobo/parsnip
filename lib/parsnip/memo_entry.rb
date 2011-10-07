module Parsnip
  class MemoEntry < Sequel::Model
    TRANSIENT_VALUES = {}

    def self.expire(range, new_string_length)
      min = :min_position.identifier
      max = :max_position.identifier
      around_min = (min <= range.min) & (max >= range.min)
      around_max = (min <= range.max) & (max >= range.max)
      dataset.filter(around_min | around_max).select(:id).each do |record|
        id = record[:id]
        dataset.filter(:id => id).delete
        TRANSIENT_VALUES.delete(id)
      end

      range_length = range.max - range.min + 1
      delta = new_string_length - range_length
      dataset.filter(:min_position.identifier > range.max).update(:min_position => :min_position + delta, :max_position => :max_position + delta)
    end
    

    def before_create
      super
      self.rule_name = rule_name.to_s
    end

    def range
      min_position..max_position
    end

    def value
      TRANSIENT_VALUES[id]
    end

    def value=(value)
      TRANSIENT_VALUES[id] = value
    end
  end
end

