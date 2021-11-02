require 'spec_helper'

describe Twinfield::Configuration do
  after do
    reset_config
  end

  it "configures username" do
    Twinfield.configure do |config|
      config.username = "my_username"
    end
    expect(Twinfield.configuration.username).to eq "my_username"
  end

  it "configures password" do
    Twinfield.configure do |config|
      config.password = "my_password"
    end
    expect(Twinfield.configuration.password).to eq "my_password"
  end

  it "configures organisation" do
    Twinfield.configure do |config|
      config.organisation = "my_organisation"
    end
    expect(Twinfield.configuration.organisation).to eq "my_organisation"
  end
end