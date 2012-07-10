if ENV['TRAVIS_BUILD'].nil?
  require 'simplecov'
  SimpleCov.start
end

require 'rubygems'
require 'bundler/setup'
require 'vcr'
require 'cgi'
require 'ideal-mollie'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :fakeweb
  c.register_request_matcher :ignore_query_param_ordering do |r1, r2|
    uri1 = URI(r1.uri)
    uri2 = URI(r2.uri)

    uri1.scheme == uri2.scheme &&
      uri1.host == uri2.host &&
        uri1.path == uri2.path &&
          CGI.parse(uri1.query) == CGI.parse(uri2.query)
  end
end

RSpec.configure
