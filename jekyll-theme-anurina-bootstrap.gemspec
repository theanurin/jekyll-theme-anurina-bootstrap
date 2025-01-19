Gem::Specification.new do |spec|
  spec.name          = "jekyll-theme-anurina-bootstrap"
  spec.summary       = "A custom Jekyll plugin with Ruby logic"

  spec.version       = File.read(File.expand_path("VERSION", __dir__))
  spec.authors       = ["Max Anurin"]
  spec.email         = ["jekyll-theme@anurin.name"]

  spec.files         = Dir["{lib}/**/*", "README.md"]
  spec.require_paths = ["lib"]

  spec.homepage      = "https://github.com/theanurin/jekyll-theme-anurina-bootstrap"
  spec.license       = "MIT"
  spec.add_runtime_dependency "jekyll", "~> 4.3.3", "< 5.0"
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata         = {}
  spec.metadata["source_code_uri"] = "https://github.com/theanurin/jekyll-theme-anurina-bootstrap"
end
