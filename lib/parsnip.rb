require 'parsnip/ast'
require 'parsnip/memo_table'
require 'parsnip/memo_entry'
require 'parsnip/parser'
require 'parsnip/parsnip.kpeg'
require 'forwardable'
require 'sequel'

module Parsnip
  def self.from_string(s)
    parser = Parsnip::FormatParser.new(s)
    raise "failed to parse: #{parser.failure_oneline}" unless parser.parse
    parser.grammar
  end
end
