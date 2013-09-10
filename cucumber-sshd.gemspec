lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH << lib unless $LOAD_PATH.include? lib
require 'cucumber/sshd/version'

Gem::Specification.new do |s|
  s.name    = 'cucumber-sshd'
  s.version = Cucumber::SSHD::VERSION
  s.summary = "cucumber-sshd-#{Cucumber::SSHD::VERSION}"
  s.description = 'Run an sshd server for scenarios tagged with @sshd'
  s.homepage = 'https://rubygems.org/gems/cucumber-sshd'

  s.authors = 'Thibault Jouan'
  s.email   = 'tj@a13.fr'

  s.files   = `git ls-files`.split $/
end
