require 'logger'

$logger = Logger.new(STDOUT) unless $logger

class ::Logger; alias_method :write, :info; end
class ::Logger; alias_method :puts, :error; end

require 'mocktopus/response'
require 'mocktopus/input'
require 'mocktopus/mock_api_call'
require 'mocktopus/input_container'
require 'mocktopus/mock_api_call_container'
require 'mocktopus/cli'
require 'mocktopus/app'

module Mocktopus
end