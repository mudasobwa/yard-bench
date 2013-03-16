$:.push File.expand_path("../lib", __FILE__)
require 'yard-bench/version'

Gem::Specification.new do |s|
  s.name = 'yard-bench'
  s.version = YARD::Bench::VERSION
  s.license = 'MIT'
  s.platform = Gem::Platform::RUBY
  s.date = '2013-02-21'
  s.authors = ['Alexei Matyushkin']
  s.email = 'am@mudasobwa.ru'
  s.homepage = 'http://github.com/mudasobwa/yard-bench'
  s.summary = %Q{Add a benchmark functionality to Yard.}
  s.description = %Q{YARD plugin, which adds a benchmarking results to YARDoc}
  s.extra_rdoc_files = [
    'LICENSE',
    'README.md'
  ]

  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.7')
  s.rubygems_version = '1.3.7'
  s.specification_version = 3

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'bueller'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'yard-cucumber'
  s.add_development_dependency 'redcarpet'
end

