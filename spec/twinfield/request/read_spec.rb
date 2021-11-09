require 'spec_helper'

describe Twinfield::Request::Read do
  include SessionStubs
  include ProcessxmlStubs

  context "Twinfield::Api::Session" do
    before do
      stub_session_wsdl
      stub_create_session
      stub_cluster_session_wsdl
      stub_select_company
      stub_processxml_wsdl
    end

    describe ".debtor" do
      pending "returns 100 sales transactions" do
        stub_processxml_read_dimensions "IVT"

        # stub_processxml_read_dimensions "DEB"
        # p Twinfield::Request::Read.debtor({})
        # expect(Twinfield::Request::Find.debtor({}).count).to eq(100)
      end
    end

    describe ".sales_invoices" do
      pending "returns sales_invoice" do
        stub_processxml_read_dimensions "IVT"

      end


    end
  end

  describe ".xml_to_nokogiri" do
    it "works for simple xml" do
      expect(Twinfield::Request::Read.xml_to_json(Nokogiri::XML("<items><item><value>1</value><key>Something</key></item></items>"))).to eq(items: [{
        value: 1, key: "Something"
      }])
       expect(Twinfield::Request::Read.xml_to_json(Nokogiri::XML("<prog>
        <prog_name>Barclay CTA Index</prog_name>
        <prog_id>9</prog_id>
      </prog>"))).to eq(:prog => {:prog_id=>9, :prog_name=>"Barclay CTA Index"})
    end
    it "works for an invoice" do
      invoice_response = File.read(File.expand_path('../../../fixtures/cluster/processxml/invoice/create_success.xml', __FILE__))
      hash = Twinfield::Request::Read.xml_to_json(Nokogiri::XML(Nokogiri::XML(invoice_response).remove_namespaces!.xpath("//ProcessXmlStringResult").text()))
      expect(hash[:salesinvoice].keys).to include :header
      expect(hash[:salesinvoice][:header][:invoicenumber]).to eq(3)
      expect(hash[:salesinvoice][:lines].count).to eq(1)
      expect(hash[:salesinvoice][:lines][0][:article]).to eq("A")
    end
  end
end