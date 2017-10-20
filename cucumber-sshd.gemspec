require File.expand_path('../lib/cucumber/sshd/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'cucumber-sshd'
  s.version     = Cucumber::SSHD::VERSION.dup
  s.summary     = 'Cucumber sshd helpers'
  s.description = 'Run an sshd server for scenarios tagged with @sshd'
  s.license     = 'BSD-3-Clause'
  s.homepage    = 'https://rubygems.org/gems/cucumber-sshd'

  s.authors     = 'Thibault Jouan'
  s.email       = 'tj@a13.fr'

  s.files       = `git ls-files lib`.split $/

  s.add_dependency 'childprocess'

  s.add_development_dependency 'cucumber', '~> 2.0'
  s.add_development_dependency 'rake', '~> 10.4'
  s.add_development_dependency 'rspec-expectations', '~> 3.7'
end
