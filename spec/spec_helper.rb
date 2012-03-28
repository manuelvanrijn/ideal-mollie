require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler/setup'
require 'vcr'
require 'ideal-mollie'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :fakeweb
end

RSpec.configure
