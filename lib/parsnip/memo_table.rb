module Parsnip
  class MemoTable
    attr_reader :db, :values

    def initialize
      @db = Sequel.sqlite
      db.create_table :memo_entries do
        primary_key :id
        String :rule_name
        Integer :begins_at
        Integer :ends_at
      end
      @values = {}
    end

    def store(rule_name, begins_at, ends_at, value)
      attributes = {
        :rule_name => rule_name.to_s,
        :begins_at => begins_at,
        :ends_at => ends_at
      }
      id = records.insert(attributes)
      values[id] = value
    end

    def retrieve(rule_name, begins_at)
      attributes = records[:rule_name => rule_name.to_s, :begins_at => begins_at]
      return unless attributes

      MemoEntry.new(attributes.merge(:value => values[attributes[:id]]))
    end

    def expire(range, new_string_length)
      conditions = "(begins_at <= #{range.min} and ends_at >= #{range.min}) or (begins_at <= #{range.max} and ends_at >= #{range.max})"
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

