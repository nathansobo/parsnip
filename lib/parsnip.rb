require 'parsnip/ast'
require 'parsnip/parser'
require 'parsnip/parsnip.kpeg'

module Parsnip
  def self.from_string(s)
    parser = Parsnip::FormatParser.new(s)
    raise "failed to parse: #{parser.failure_oneline}" unless parser.parse
    parser.grammar
  end
end
