require 'logger'
LOGGER = Logger.new('mocktopus.log', 'daily')

require 'mocktopus/response'
require 'mocktopus/input'
require 'mocktopus/mock_api_call'
require 'mocktopus/input_container'
require 'mocktopus/mock_api_call_container'
require 'mocktopus/cli'
require 'mocktopus/app'

module Mocktopus
end