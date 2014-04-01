require File.expand_path('../lib/cucumber/sshd/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'cucumber-sshd'
  s.version = Cucumber::SSHD::VERSION.dup
  s.summary = 'Cucumber sshd helpers'
  s.description = 'Run an sshd server for scenarios tagged with @sshd'
  s.homepage = 'https://rubygems.org/gems/cucumber-sshd'

  s.authors = 'Thibault Jouan'
  s.email   = 'tj@a13.fr'

  s.files   = `git ls-files`.split $/

  s.add_dependency 'aruba', '~> 0.5'
end
