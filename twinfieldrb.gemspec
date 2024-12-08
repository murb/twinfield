$:.push File.expand_path("../lib", __FILE__)
require "twinfield/version"

Gem::Specification.new do |s|
  s.name = "twinfieldrb"
  s.version = Twinfield::Version::VERSION
  s.authors = ["Ernst Rijsdijk", "Stephan van Diepen", "Joris Reijrink", "Maarten Brouwers"]
  s.email = ["ernst.rijsdijk@holder.nl", "s.vandiepen@noxa.nl", "joris@sprintict.nl", "maarten@murb.nl"]
  s.homepage = "https://github.com/murb/twinfield"
  s.summary = "A simple client for the Twinfield SOAP-based API (continuation of the twinfield gem)"
  s.description = "Twinfield is an international Web service for collaborative online accounting. The Twinfield gem is a simple client for their SOAP-based API."

  # s.rubyforge_project = "twinfield"

  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "savon", "~> 2.10"
  s.add_runtime_dependency "nokogiri", "~> 1.6"
  s.add_development_dependency "rspec"
  s.add_development_dependency "standard"
  s.add_development_dependency "webmock"
end
