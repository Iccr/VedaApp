# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','veda','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'veda-apps'
  s.version = Veda::VERSION
  s.author = 'Shishir sapkota'
  s.email = 'sis.ccr@gmail.com'
  s.homepage = 'https://github.com/Iccr'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Automate the Ios Tasks'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['veda.rdoc']
  s.rdoc_options << '--title' << 'veda' << '--main'  << '-ri'
  s.bindir = 'bin'
  s.executables << 'veda'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('rest-client')
  s.add_runtime_dependency('gli','2.17.1')
end
