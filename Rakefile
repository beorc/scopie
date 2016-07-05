# frozen_string_literal: true
require 'bundler/gem_tasks'

task :console do
  require 'pry'
  lib = File.expand_path('lib')
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
  require 'scopie'
  ARGV.clear
  Pry.start
end

task :release_tag do
  system "git commit -a -m 'Release #{Scopie::VERSION}'"
  system "git tag -a v#{Scopie::VERSION} -m 'version #{Scopie::VERSION}'"
end

desc 'Push to Github'
task :push do
  system 'git push --tags origin master'
end

desc 'Build the gem'
task :build do
  system 'bundle exec gem build scopie.gemspec'
end

desc "Release version #{Scopie::VERSION}"
task release: [:build, :release_tag, :push] do
  system "bundle exec gem push scopie-#{Scopie::VERSION}.gem"
end
