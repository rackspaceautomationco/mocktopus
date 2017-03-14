require 'thor'

module Mocktopus
  class CLI < Thor
    include Thor::Actions

    desc "start", "starts the mocktopus"
    method_option :port, :desc => "specifies the port to run the mocktopus"
    def start(*args)
      port_option = args.include?('-p') ? '' : ' -p 8081'
      args = args.join(' ')
      command = "bundle exec thin -R #{ENV['CONFIG_RU'] || 'config.ru'} start#{port_option} #{args}"
      Kernel.system(command)
    end

    desc "stop", "stops the mocktopus"
    def stop
      command = "bundle exec thin stop"
      Kernel.system(command)
    end

    map 's' => :start
    
  end
end
