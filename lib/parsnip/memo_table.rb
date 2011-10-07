module Parsnip
  class MemoTable
    attr_reader :db, :values

    def initialize
      @db = Sequel.sqlite
      db.create_table :memo_entries do
        primary_key :id
        String :rule_name
        Integer :min_position
        Integer :max_position
        Integer :length
      end
      @values = {}
    end

    def store(attributes)
      attributes[:rule_name] = attributes[:rule_name].to_s
      value = attributes.delete(:value)
      id = records.insert(attributes)
      values[id] = value
    end

    def retrieve(rule_name, min_position)
      return unless attributes = records[:rule_name => rule_name.to_s, :min_position => min_position]
      attributes[:value] = values[attributes[:id]]
      MemoEntry.new(attributes)
    end

    def expire(range, new_string_length)
      min = :min_position.identifier
      max = :max_position.identifier
      around_min = (min <= range.min) & (max >= range.min)
      around_max = (min <= range.max) & (max >= range.max)
      records.filter(around_min | around_max).select(:id).each do |record|
        id = record[:id]
        records.filter(:id => id).delete
        values.delete(id)
      end

      range_length = range.max - range.min + 1
      delta = new_string_length - range_length
      records.filter("min_position > #{range.max}").update(:min_position => :min_position + delta, :max_position => :max_position + delta)
    end

    def empty?
      records.count == 0
    end

    def size
      records.count
    end

    def records
      db[:memo_entries]
    end
  end
end

