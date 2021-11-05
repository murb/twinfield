require 'spec_helper'

describe Twinfield::Create::Invoice do
  include SessionStubs
  include ProcessxmlStubs

  describe Twinfield::Create::Invoice::Line do
    describe "#to_xml" do
      it "renders xml" do
        expect(Twinfield::Create::Invoice::Line.new(article: "A").to_xml(1)).to match("<line id=\"1\">")
        expect(Twinfield::Create::Invoice::Line.new(article: "A", id: 2).to_xml()).to match("<line id=\"2\">")
      end
      it "formats dates correctly" do
        expect(Twinfield::Create::Invoice::Line.new(article: "A", performancedate: Date.new(2020,12,23)).to_xml(1)).to match("20201223")
      end
    end
  end

  describe "#to_xml" do
    it "renders xml" do
      invoice = Twinfield::Create::Invoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP")
      invoice.invoice_lines= [Twinfield::Create::Invoice::Line.new(article: "A")]
      expect(invoice.to_xml).to match("<lines>\n    <line id=\"1\">")
    end
  end

  describe "#save" do
    before do
      stub_session_wsdl
      stub_create_session
      stub_cluster_session_wsdl
      stub_select_company
      stub_processxml_wsdl
    end


    it "reports errors" do
      stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
        with(body: /<customer>1001<\/customer>/).
        to_return(body: File.read(File.expand_path('../../../fixtures/cluster/processxml/invoice/create_error.xml', __FILE__)))
      invoice = Twinfield::Create::Invoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP")
      expect{ invoice.save }.to raise_error(Twinfield::Create::Error)
    end

    it "succeeds" do
      stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
        with(body: /<customer>1001<\/customer>/).
        to_return(body: File.read(File.expand_path('../../../fixtures/cluster/processxml/invoice/create_success.xml', __FILE__)))
      invoice = Twinfield::Create::Invoice.new(duedate: Time.now, customer: "1001", invoicetype: "VERKOOP")
      saved_invoice = invoice.save
      expect(saved_invoice.invoicenumber).to eq("3")
    end

  end
end
