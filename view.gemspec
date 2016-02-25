# encoding: utf-8
# frozen_string_literal: true
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'view/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'view'
  s.version     = View::VERSION
  s.authors     = ['Josh Deeden']
  s.email       = ['jdeeden@gmail.com']
  s.homepage    = 'http://github.com/gangster/view'
  s.summary     = 'Clean up those Rails views, son!'
  s.description = 'A set of simple, east to use abstractions for cleaning up your views.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*',
                'MIT-LICENSE',
                'Rakefile',
                'README.rdoc']

  s.test_files = Dir['spec/**/*']
  s.require_paths = ['lib']

  s.add_dependency 'rails', '~> 4.2.5.1'
  s.add_dependency 'backport_new_renderer'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'rubocop'
end
