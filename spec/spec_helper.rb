require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler/setup'
require 'vcr'
require 'ideal-mollie'

VCR.config do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.stub_with :fakeweb
end

RSpec.configure
