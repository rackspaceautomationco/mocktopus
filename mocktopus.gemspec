# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'mocktopus'
  s.version     = '0.1.2'
  s.date        = '2016-08-25'
  s.required_ruby_version = '>= 2.0.0'

  s.summary     = 'A configurable mock Web API'
  s.description = 'The Mocktopus is a Sinatra/thin-based Web API that lets you mock your app dependencies'
  s.author      = 'Rackspace'
  s.email       = ['racksburg_automation@lists.rackspace.com']
  s.homepage    = 'https://github.com/rackspaceautomationco/mocktopus'
  
  s.files = Dir.glob("{bin,lib}/**/*") + %w(MIT-LICENSE README.md Gemfile mocktopus.gemspec config.ru ascii.rb)
  s.executables = %w(mocktopus)

  s.add_dependency 'sinatra', '~> 1.4', '>= 1.4.4'
  s.add_dependency 'sinatra-contrib', '~> 1.4.2', '>= 1.4.2'
  s.add_dependency 'thin', '~> 1.6.1', '>= 1.6.1'
  s.add_dependency 'thor', '~> 0.19.1', '>= 0.19.1'
  s.add_dependency 'rack', '~> 1.5.2', '>= 1.5.2'
  s.add_dependency 'rake', '~> 10.1.0', '>= 10.1.0'
  s.add_dependency 'minitest', '~> 5.2.0', '>= 5.2.0'
  s.add_dependency 'fakeweb', '~> 1.3.0', '>= 1.3.0'
  s.add_dependency 'mocha', '~> 0.14.0', '>= 0.14.0'
  s.add_dependency 'simplecov', '~> 0.9.2', '>= 0.9.2'
  s.add_dependency 'coveralls', '~> 0.7.11', '>= 0.7.11'
  s.add_dependency 'pry', '~> 0.10.1', '>= 0.10.1'
end
