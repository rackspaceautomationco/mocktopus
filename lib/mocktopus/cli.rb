require 'thor'

module Mocktopus
  class CLI < Thor
    include Thor::Actions

    desc "start", "starts the mocktopus"
    method_option :port, :desc => "specifies the port to run the mocktopus"
    def start(*args)
      port_option = args.include?('-p') ? '' : ' -p 8081'
      args = args.join(' ')
      command = "bundle exec thin -R config.ru start#{port_option} #{args}"
      run_command(command)
    end

    desc "stop", "stops the mocktopus"
    def stop
      command = "bundle exec thin stop"
      run_command(command)
    end

    map 's' => :start

    private

    def run_command(command)
      system(command)
    end
    
  end
end
