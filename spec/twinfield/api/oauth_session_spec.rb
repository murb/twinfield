require 'spec_helper'

describe Twinfield::Api::OAuthSession do
  include SessionStubs

  context "OAuth configured" do
    before do
      Twinfield.configure do |config|
        config.session_type = "Twinfield::Api::OAuthSession"
        config.cluster = "https://accounting.twinfield.com"
        config.access_token = "2b128baa05dd3cabc61e534435884961"
      end
    end

    after do
      Twinfield.configure do |config|
        config.session_type = nil
        config.cluster = nil
        config.access_token = nil
      end
    end

    it "returns true when oauth is configured" do
      session = Twinfield::Api::OAuthSession.new

      expect(session.connected?).to be_truthy
    end
  end

  describe "#connected?" do
    it "returns false when no access token is supplied" do
      session = Twinfield::Api::OAuthSession.new

      expect(session.connected?).to be_falsey
    end
  end
end

