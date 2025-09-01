require "spec_helper"

describe Twinfield::Request::List do
  include SessionStubs
  include ProcessxmlStubs

  context "Twinfield::Api::Session" do
    before do
      stub_create_session
      stub_cluster_session_wsdl
      stub_select_company
    end

    describe "#dimensions" do
      it "lists debtors" do
        stub_processxml_list_dimensions(dimension_type: "DEB", company: "company")
        expect(subject.dimensions({dimtype: "DEB"})).to be_a Nokogiri::XML::Document
      end
    end
  end

  context "Twinfield::Api::OAuthSession" do
    before do
      #
      # stub_cluster_session_wsdl

      Twinfield.configure do |config|
        config.session_type = "Twinfield::Api::OAuthSession"
        config.cluster = "https://accounting.twinfield.com"
        config.access_token = "2b128baa05dd3cabc61e534435884961"
        # config.log_level = :debug
      end
    end

    after do
      Twinfield.configure do |config|
        config.session_type = nil
        config.cluster = nil
        config.access_token = nil
        config.log_level = nil
      end
    end

    describe "#dimensions" do
      it "lists debtors" do
        stub_processxml_list_dimensions(dimension_type: "DEB", oauth: true)
        expect(subject.dimensions({dimtype: "DEB"})).to be_a Nokogiri::XML::Document
      end
    end

    describe "#offices" do
      it "lists offices" do
        stub_processxml_list_offices(oauth: true)
        subject.offices
      end
    end
  end
end
