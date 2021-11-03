require 'spec_helper'

describe Twinfield::Request::List do
  include SessionStubs
  include ProcessxmlStubs

  context "Twinfield::Session" do
    before do
      stub_session_wsdl
      stub_create_session
      stub_cluster_session_wsdl
      stub_select_company
      stub_processxml_wsdl
    end

    describe "#dimensions" do
      it "lists debtors" do
        stub_processxml_list_dimensions(dimension_type: 'DEB')
        expect(subject.dimensions({ dimtype: "DEB" })).to be_a Nokogiri::XML::Document
      end
    end
  end

  context "Twinfield::OAuthSession" do
    before do
      # stub_session_wsdl
      # stub_cluster_session_wsdl
      stub_processxml_wsdl

      Twinfield.configure do |config|
        config.session_type = "Twinfield::OAuthSession"
        config.cluster = "https://accounting.twinfield.com"
        config.access_token = "2b128baa05dd3cabc61e534435884961"
      end

      Twinfield::Process.session= nil
      Twinfield::Finder.session= nil
    end

    after do
      Twinfield.configure do |config|
        config.session_type = nil
        config.cluster = nil
        config.access_token = nil
      end
    end

    describe "#dimensions" do
      it "lists debtors" do
        stub_processxml_list_dimensions(dimension_type: 'DEB', oauth: true)
        expect(subject.dimensions({ dimtype: "DEB" })).to be_a Nokogiri::XML::Document
      end
    end

  end

end
