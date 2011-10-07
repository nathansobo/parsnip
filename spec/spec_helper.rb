require 'rubygems'
require 'bundler/setup'
require 'parsnip'

include Parsnip

RSpec.configure do |c|
  c.before do
    Parsnip::DB[:memo_entries].delete
    Parsnip::MemoEntry::TRANSIENT_VALUES.clear
  end
end
