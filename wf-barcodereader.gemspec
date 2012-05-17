# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wf-barcodereader/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yann Marquet"]
  gem.email         = ["ymarquet@gmail.com"]
  gem.description   = %q{This gem provide a way to scan QR barecode with apple isight or face time intergrated webcam  }
  gem.summary       = %q{This gem provide a way to scan QR barecode with apple isight or face time intergrated webcam  }
  gem.homepage      = "https://github.com/StupidCodeFactory/wf-barcodereader"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wf-barcodereader"
  gem.require_paths = ["lib"]
  gem.version       = Wf::Barcodereader::VERSION
  
  gem.add_dependency 'zbar'
  gem.add_dependency 'rmagick'
end
