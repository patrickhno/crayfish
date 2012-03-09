
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "crayfish/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "crayfish"
  s.version     = Crayfish::VERSION
  s.authors     = ["Patrick Hanevold"]
  s.email       = ["patrick.hanevold@gmail.com"]
  s.homepage    = "http://github.com/patrickhno"
  s.summary     = "Crayfish - PDF templating for Rails"
  s.description = "Crayfish - PDF templating for Rails"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency "prawn"
  s.add_dependency "nokogiri"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mocha"
end
