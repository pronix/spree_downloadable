Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_downloadable'
  s.version     = '1.0.0'
  s.summary     = ''
  s.description = 'sell digital products'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'pronix.service@gmail.com'
  s.email             = 'pronix.service@gmail.com'
  s.homepage          = 'http://tradefast.ru'
  # s.rubyforge_project = 'actionmailer'

  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 0.30.0')
  s.add_dependency('paperclip', '>=2.3.6')
  s.add_dependency('aasm','>= 2.2.0')
end
