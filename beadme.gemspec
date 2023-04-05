version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name = 'beadme'
  s.version = version
  s.summary = 'README.md generator'
  s.description = 'README generator for projects'
  s.authors = ['Wai Yan Phyo']
  s.email = 'oyhpnayiaw@gmail.com'
  s.files = Dir[
    'lib/**/*',
    'bin/*',
    'config/*',
    'templates/*',
    'README.markdown',
    'LICENSE',
    'VERSION'
  ]
  s.bindir = 'bin'
  s.executables = ['beadme']
  s.required_ruby_version = '>= 2.6.0'
  s.homepage =
    'https://rubygems.org/gems/beadme'
  s.license = 'MIT'
  s.metadata = {
    'source_code_uri' => 'https://github.com/oyhpnayiaw/beadme',
    'rubygems_mfa_required' => 'true'
  }

  s.add_runtime_dependency 'thor', '~> 1.2'
end
