$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pigrider_user/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pigrider_user"
  s.version     = PigriderUser::VERSION
  s.authors     = ["Dingyu Zhou"]
  s.email       = ["dingyu.zhou@colorado.edu"]
  s.homepage    = "http://pigrider.com"
  s.summary     = "This is a user account management engine for all pigRider applications."
  s.description = "This is a user account management engine for all pigRider applications."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  # s.add_dependency "jquery-rails"

  s.add_dependency "bcrypt"
  s.add_development_dependency "mysql2"
end
