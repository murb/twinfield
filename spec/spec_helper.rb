require File.expand_path("../../lib/twinfield", __FILE__)
require "webmock/rspec"

Dir.glob(File.expand_path("../stubs/*.rb", __FILE__), &method(:require))

def reset_config
  Twinfield.configure do |config|
    config.username = "username"
    config.password = "password"
    config.organisation = "organisation"
    config.company = "company"
  end
end

RSpec.configure do |config|
  config.before(:all) { reset_config }
end
