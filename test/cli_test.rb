require 'test_helper'

class CLITest < Mocktopus::Test
  def setup
    @cli = Mocktopus::CLI.new
  end

  def test_start_task_starts_mocktopus_with_default_port
    command = 'bundle exec thin -R config.ru start -p 8081 '
    Kernel.expects(:system).with(command).once
    @cli.start
  end

  def test_start_task_starts_mocktopus_with_custom_port
    command = 'bundle exec thin -R config.ru start -p 7071'
    Kernel.expects(:system).with(command).once
    @cli.start('-p', '7071')
  end

  def test_stop_task_stops_mocktopus
    Kernel.expects(:system).with('bundle exec thin stop')
    @cli.stop
  end

end
