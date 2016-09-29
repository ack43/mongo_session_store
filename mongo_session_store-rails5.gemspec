require File.expand_path('../lib/mongo_session_store/version', __FILE__)

Gem::Specification.new do |s|
  s.name = File.basename(__FILE__).gsub(".gemspec", "")
  s.version = MongoSessionStore::VERSION

  s.authors          = ["Alexander Kiseliev", "Brian Hempel", "Nicolas M\303\251rouze", "Tony Pitale", "Chris Brickley"]
  s.email            = ["i43ack@gmail.com", "plasticchicken@gmail.com"]
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features,perf}/*`.split("\n")
  s.homepage         = "https://github.com/ack43/mongo_session_store"
  s.license          = "MIT"
  s.require_paths    = ["lib"]
  s.rubygems_version = "1.3.7"
  s.summary          = "Rails session stores for MongoMapper, Mongoid, or any other ODM. Rails 5.0 compatible."

  s.add_dependency "actionpack", ">= 3.1"

  s.add_dependency 'rails', ['>=5.0', "<6.0"]
end
