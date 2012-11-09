require './lib/copperegg/version'

Gem::Specification.new do |s|
  s.name = 'copperegg'
  s.version = CopperEgg::VERSION
  s.author = 'Eric Anderson'
  s.email = 'anderson@copperegg.com'

  s.description = 'Library for using the CopperEgg REST API'
  s.summary = 'Library for using the CopperEgg REST API'
  s.homepage = 'http://github.com/copperegg/copperegg-ruby'
  s.license = '???'

  s.platform = Gem::Platform::RUBY
  s.require_paths = %w[lib]
  s.files         = Dir["#{File.dirname(__FILE__)}/**/*"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  #s.add_dependency('multi_json', '>= 1.3.0')
  #...

  #s.add_development_dependency 'rake',    '~> 0.9.0'

  #s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'copperegg-ruby', '--main', 'README.md']
end
