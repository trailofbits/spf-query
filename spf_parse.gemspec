# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spf_parse/version'

Gem::Specification.new do |gem|
  gem.name          = "spf_parse"
  gem.version       = SPFParse::VERSION
  gem.authors       = ["nicktitle"]
  gem.email         = ["nick.esposito@trailofbits.com"]
  gem.summary       = %q{SPF Retriever and Parser}
  gem.description   = %q{Search and retrieve SPF records for any number of hosts}
  gem.homepage      = "https://github.com/trailofbits/spf_parse#readme"
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = ['spf']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.required_ruby_version = '>= 1.9.1'

  gem.add_dependency "parslet", "~> 1.0"

  gem.add_development_dependency "bundler", "~> 1.6"
  gem.add_development_dependency "rake", "~> 10.0"
end
