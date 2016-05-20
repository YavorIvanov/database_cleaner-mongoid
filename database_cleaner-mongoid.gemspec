require 'yaml'
version = YAML.load_file 'VERSION.yml'

Gem::Specification.new do |s|
  s.name = "database_cleaner-mongoid"
  s.version = "#{version[:major]}.#{version[:minor]}.#{version[:patch]}"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = ">= 1.9.3"
  s.require_paths = ["lib"]
  s.authors = ["Ernesto Tagwerker"]
  s.description = "Strategies for cleaning databases with Mongoid. Can be used to ensure a clean state for testing."
  s.email = "ernesto@ombulabs.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.markdown",
    "TODO"
  ]
  s.files = [
    "CONTRIBUTE.markdown",
    "Gemfile.lock",
    "History.rdoc",
    "README.markdown",
    "Rakefile",
    "VERSION.yml",
    "cucumber.yml"]

  s.files += Dir['examples/**/*'] + Dir['features/**/*'] + Dir['lib/**/*.rb'] +
             Dir['spec/**/*']

  s.homepage = "http://github.com/DatabaseCleaner/database_cleaner-mongoid"
  s.license = 'MIT'

  s.rubygems_version = "2.4.5"
  s.summary = "Strategies for cleaning databases with Mongoid.  Can be used to ensure a clean state for testing."

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "json_pure"
  s.add_development_dependency "mongoid"
  s.add_development_dependency "mongoid-tree"
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency "rspec-rails", "~> 2.14.2"
  s.add_development_dependency "cucumber"

  unless RUBY_PLATFORM =~ /java/
    s.add_development_dependency "mongo_ext"
    s.add_development_dependency "bson_ext"
  end
end
