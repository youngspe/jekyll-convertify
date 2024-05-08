# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "jekyll-convertify"
  gem.version       = "0.1.0"
  gem.authors       = ["Spencer Young"]
  gem.email         = ["spencerwyoung@outlook.com"]
  gem.description   = %q{Provides tags and filters to convert sources of one type to another type, e.g. Markdown to HTML.}
  gem.summary       = %q{Convert sections of a document from one type to another.}
  gem.homepage      = "https://github.com/youngspe/jekyll-convertify"

  gem.files         = [
    "lib/jekyll-convertify.rb",
    "lib/jekyll-convertify/convert.rb",
    "lib/jekyll-convertify/convertify-filters.rb",
    "lib/jekyll-convertify/tags.rb"
  ]
  gem.require_paths = ["lib"]
  gem.license       = "MIT"

  gem.add_runtime_dependency 'jekyll',     '>= 3.6', '< 5.0'
end
