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
      id = db[:memo_entries].insert(attributes)
      values[id] = value
    end

    def retrieve(rule_name, begins_at)
      attributes = db[:memo_entries].filter(:rule_name => rule_name.to_s, :begins_at => begins_at).first
      return unless attributes

      MemoEntry.new(attributes.merge(:value => values[attributes[:id]]))
    end
  end
end

