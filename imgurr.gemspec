Gem::Specification.new do |s|
  s.name        = 'imgurr'
  s.version     = '0.1.0'
  s.date        = '2013-04-17'
  s.summary     = "Imgurr lets you upload images to imgur from the command line"
  s.description = "Imgurr is a ruby gem that lets you upload images to Imgur and manage your account"
  s.authors     = ["Christophe Naud-Dulude"]
  s.email       = 'christophe.naud.dulude@gmail.com'
  s.homepage    = 'https://github.com/Chris911/imgurr'

  s.require_paths = %w[lib]
  ## If your gem includes any executables, list them here.
  s.executables = ["imgurr"]
  s.default_executable = 'imgurr'

  s.add_dependency('json', "~> 1.7.0")

  s.add_development_dependency('rake', "~> 0.9.2")

  ## Specify any RDoc options here. You'll want to add your README and
  ## LICENSE files to the extra_rdoc_files list.
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE.md]

  s.license = 'MIT'

  s.files             = %w( README.md LICENSE.md Gemfile Gemfile.lock imgurr.gemspec Rakefile)
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("test/**/*")
end