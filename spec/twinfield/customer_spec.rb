require 'spec_helper'

describe Twinfield::Customer do
  include SessionStubs
  include ProcessxmlStubs

  describe "class methods" do
    before do
      stub_session_wsdl
      stub_create_session
      stub_cluster_session_wsdl
      stub_select_company
      stub_processxml_wsdl
    end

    describe ".find" do
      it "returns a sales invoice" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
          with(body: /\<dimtype\>DEB\<\/dimtype\>/).
          to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/customer/read_success.xml', __FILE__)))
        customer = Twinfield::Customer.find(1000)
        p customer.inspect.gsub("<", "[")
      end
    end
  end
end