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

def requested_signatures_matching request
  WebMock::RequestRegistry.instance.requested_signatures.select { |a| request.matches? a }.keys
end

def save_requested_signature_body_matching request, file_name: Tempfile.new("mock_body")
  requests = WebMock::RequestRegistry.instance.requested_signatures.select { |a| request.matches? a }.keys
  if requests.count == 1
    File.write(file_name, requests.first.body)
    file_name
  else
    binding.irb
    raise "Expected 1 matching request, got #{requests.count}"
  end
end
