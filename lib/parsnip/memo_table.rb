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
      end
      @values = {}
    end

    def store(rule_name, min_position, max_position, value)
      attributes = {
        :rule_name => rule_name.to_s,
        :min_position => min_position,
        :max_position => max_position
      }
      id = records.insert(attributes)
      values[id] = value
    end

    def retrieve(rule_name, min_position)
      attributes = records[:rule_name => rule_name.to_s, :min_position => min_position]
      return unless attributes

      MemoEntry.new(attributes.merge(:value => values[attributes[:id]]))
    end

    def expire(range, new_string_length)
      conditions = "(min_position <= #{range.min} and max_position >= #{range.min}) or (min_position <= #{range.max} and max_position >= #{range.max})"
      records.filter(conditions).select(:id).each do |record|
        id = record[:id]
        records.filter(:id => id).delete
        values.delete(id)
      end
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

