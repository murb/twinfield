require 'spec_helper'

describe Twinfield::Customer do
  include SessionStubs
  include ProcessxmlStubs

  before do
    stub_session_wsdl
    stub_create_session
    stub_cluster_session_wsdl
    stub_select_company
    stub_processxml_wsdl
  end

  describe "class methods" do
    describe ".find" do
      it "returns a sales invoice" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /\<dimtype\>DEB\<\/dimtype\>/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/customer/read_success.xml', __FILE__)))
        customer = Twinfield::Customer.find(1000)
        expect(customer.name).to eq("Waardedijk")
        expect(customer.financials.childvalidations).to eq("1300")
      end
    end
  end

  describe "instance methods" do
    describe "#to_xml" do
      it "returns returns nokogiri xml" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /\<dimtype\>DEB\<\/dimtype\>/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/customer/read_success.xml', __FILE__)))
        customer = Twinfield::Customer.find(1000)
        recreated_customer = Twinfield::Customer.from_xml(Nokogiri::XML(customer.to_xml))

        expect(recreated_customer.name).to eq(customer.name)
        expect(recreated_customer.financials.ebillmail).to eq(customer.financials.ebillmail)
        expect(recreated_customer.addresses[0].name).to eq(customer.addresses[0].name)
      end
    end
  end
end


