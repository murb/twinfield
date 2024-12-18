require "spec_helper"

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

  describe "#session_class" do
    it "returns a session class" do
      expect(Twinfield.configuration.session_class).to eq(Twinfield::Api::Session)
    end

    it "returns a oauth session class when configured" do
      Twinfield.configure do |config|
        config.session_type = "Twinfield::Api::OAuthSession"
      end
      expect(Twinfield.configuration.session_class).to eq(Twinfield::Api::OAuthSession)
      Twinfield.configure do |config|
        config.session_type = nil
      end
    end
  end

  describe "#access_token_expired?" do
    it "raises when no access token is given" do
      expect { Twinfield.configuration.access_token_expired? }.to raise_error(Twinfield::Configuration::Error)
    end

    it "returns expired on an old access token" do
      Twinfield.configuration.access_token = "abc.#{Base64.encode64(JSON({exp: (Time.now - 100).to_i}))}.abc"
      expect(Twinfield.configuration.access_token_expired?).to eq(true)
    end

    it "returns not expired on an old access token" do
      Twinfield.configuration.access_token = "abc.#{Base64.encode64(JSON({exp: (Time.now + 100).to_i}))}.abc"
      expect(Twinfield.configuration.access_token_expired?).to eq(false)
    end
  end
end
