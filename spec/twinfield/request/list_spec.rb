require 'spec_helper'

describe Twinfield::Request::List do
  include SessionStubs
  include ProcessxmlStubs

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
