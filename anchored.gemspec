require "./lib/anchored/version"

Gem::Specification.new do |spec|
  spec.name          = "anchored"
  spec.version       = Anchored::VERSION
  spec.authors       = ["Tee Parham"]
  spec.email         = ["tee@neighborland.com"]

  spec.summary       = "Ruby auto linker"
  spec.description   = "Ruby auto linker based on rails_autolink. "\
                       "It wraps links in text with HTML anchors."
  spec.homepage      = "https://github.com/neighborland/anchored"
  spec.license       = "MIT"

  spec.files         = Dir["LICENSE.txt", "README.md", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.10"
  spec.add_development_dependency "activesupport", "~> 5.0"
end
