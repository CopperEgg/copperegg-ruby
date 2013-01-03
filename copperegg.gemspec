require './lib/copperegg/ver'

Gem::Specification.new do |s|
  s.name    = 'copperegg'
  s.version = CopperEgg::GEM_VERSION
  s.author  = 'Eric Anderson'
  s.email   = 'anderson@copperegg.com'

  s.description = 'Library for using the CopperEgg REST API'
  s.summary   = 'Library for using the CopperEgg REST API'
  s.homepage  = 'http://github.com/copperegg/copperegg-ruby'
  s.license   = 'MIT'

  s.platform = Gem::Platform::RUBY
  s.require_paths = %w[lib]
  s.files         = Dir["#{File.dirname(__FILE__)}/**/*"]
  s.test_files    = Dir.glob("{test,spec,features}/*")
  s.executables   = Dir.glob("bin/*")

  s.add_dependency('json_pure', '~> 1.7.6')

  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'copperegg-ruby', '--main', 'README.md']
end
