require_relative 'lib/evdev/version'

Gem::Specification.new do |spec|
  spec.name          = "evdev"
  spec.version       = Evdev::VERSION
  spec.authors       = ["Christopher Aue"]
  spec.email         = ["rubygems@christopheraue.net"]

  spec.summary       = %q{A ruby object wrapper around libevdev bindings.}
  spec.homepage      = "https://github.com/christopheraue/ruby-evdev"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "libevdev", "~> 1.0"
  spec.add_runtime_dependency "callbacks_attachable", "~> 2.3"
end
