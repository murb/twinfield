require 'spec_helper'

describe Twinfield::Api::Session do
  include SessionStubs

  after do
    reset_config
  end

  describe "successful logon" do

    before(:all) do
      stub_session_wsdl
      stub_create_session
      stub_cluster_session_wsdl
      stub_select_company
      @session = Twinfield::Api::Session.new
      @session.logon
    end

    it "should return successful message" do
      expect(@session.status).to eq "Ok"
    end

    it "should return that the current session already is connected" do
      expect(@session.logon).to eq "already connected"
    end

    it "should return that the current session already is connected" do
      stub_create_session
      stub_cluster_session_wsdl
      stub_select_company
      expect(@session.relog).to eq "Ok"
    end

    it "should have a session_id after successful logon" do
      expect(@session.session_id).not_to eq nil
    end

    it "should have a cluster after successful logon" do
      expect(@session.cluster).not_to eq nil
    end

    it "should return true for connected" do
      expect(@session.connected?).to eq true
    end
  end

  describe "invalid logon" do

    before(:all) do
      username = "not_valid_username"
      stub_session_wsdl
      stub_create_session username: username, response: "Invalid"

      Twinfield.configure do |config|
        config.username = username
      end

      @session = Twinfield::Api::Session.new
      @session.logon
    end

    it "should return invalid message" do
      expect(@session.status).to eq "Invalid"
    end

    it "should not have a session_id" do
      expect(@session.session_id).to eq nil
    end

    it "should not have a cluster" do
      expect(@session.cluster).to eq nil
    end

    it "should return false for connected" do
      expect(@session.connected?).to eq false
    end
  end
end