require 'mocktopus'

class LoggerMiddleware

  def initialize(app, logger)
    @app, @logger = app, logger
  end

  def call(env)
    env['rack.errors'] = @logger
    @app.call(env)
  end

end

use Rack::CommonLogger, $logger
use LoggerMiddleware, $logger
set :show_exceptions, false

run Sinatra::Application