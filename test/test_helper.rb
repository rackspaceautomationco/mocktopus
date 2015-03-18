require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]

SimpleCov.start do
  add_filter '/test/'
  add_filter '/ascii.rb'
end

require 'rack/test'
require 'tmpdir'
require 'fakeweb'
require 'minitest/autorun'
require 'mocha/setup'

require_relative '../lib/mocktopus'

FakeWeb.allow_net_connect = %r[^https?://coveralls.io]

ENV['RACK_ENV'] = 'test'
WORKING_DIRECTORY = Dir.pwd.freeze
ARGV.clear

module Mocktopus
  class Test < Minitest::Test
    include Rack::Test::Methods

  end
end
