require 'spec_helper'

describe Twinfield::Request::Read do
  include SessionStubs
  include ProcessxmlStubs

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