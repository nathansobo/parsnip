require 'forwardable'
require 'sequel'

module Parsnip
  DB = Sequel.sqlite
  Sequel::Model.db = DB
  DB.create_table :memo_entries do
    primary_key :id
    String :rule_name
    Integer :min_position
    Integer :max_position
    Integer :length
  end

  def self.from_string(s)
    parser = Parsnip::FormatParser.new(s)
    raise "failed to parse: #{parser.failure_oneline}" unless parser.parse
    parser.grammar
  end
end

require 'parsnip/ast'
require 'parsnip/memo_entry'
require 'parsnip/parser'
require 'parsnip/parsnip.kpeg'

