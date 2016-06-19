$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'scopie/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'scopie'
  s.version     = Scopie::VERSION
  s.authors     = ['Yury Kotov']
  s.email       = ['non.gi.suong@ya.ru']
  s.homepage    = 'https://github.com/beorc/scopie'
  s.summary     = 'Maps HTTP-parameters to your resource scopes'
  s.description = 'Minimal mapping of incoming parameters to named scopes in your resources through OO design and pure Ruby classes'
  s.license     = "MIT"

  s.files = Dir['{lib}/**/*', 'LICENSE', 'README.md']
end
