require 'spec_helper'

describe Twinfield::Customer do
  include SessionStubs
  include FinderStubs
  include ProcessxmlStubs

  before do
    stub_session_wsdl
    stub_create_session
    stub_cluster_session_wsdl
    stub_select_company
    stub_processxml_wsdl
    stub_finder_wsdl
  end

  let(:existing_customer) do
    stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
      with(body: /\<dimtype\>DEB\<\/dimtype\>/).
      to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/customer/read_success.xml', __FILE__)))
    Twinfield::Customer.find(1000)
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
        expect(customer.addresses[0].default).to eq("true")
        expect(customer.addresses[0].type).to eq("invoice")
      end
    end

    describe ".all" do
      it "returns a list of customers" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/finder.asmx")
        .with(body: /\>\<string\>dimtype\<\/string\>\<string\>DEB\<\/string\>/)
        .to_return(body: '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><SearchResponse xmlns="http://www.twinfield.com/"><SearchResult /><data><TotalRows>17</TotalRows><Columns><string>Code</string><string>Naam</string></Columns><Items><ArrayOfString><string>1000</string><string>Waardedijk</string></ArrayOfString><ArrayOfString><string>1001</string><string>Witteveen</string></ArrayOfString><ArrayOfString><string>1002</string><string>Bosman</string></ArrayOfString><ArrayOfString><string>1003</string><string>Samkalde</string></ArrayOfString></Items></data></SearchResponse></soap:Body></soap:Envelope>')

        customers = Twinfield::Customer.all
        expect(customers.length).to eq(4)
        expect(customers[0]).to be_a Twinfield::Customer
        expect(customers.map{|a| a.name}).to include("Waardedijk")
      end
    end

    describe ".search" do
      it "accepts a search param" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/finder.asmx")
        .with(body: /\>\<string\>dimtype\<\/string\>\<string\>DEB\<\/string\>/)
        .to_return(body: '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><SearchResponse xmlns="http://www.twinfield.com/"><SearchResult /><data><TotalRows>17</TotalRows><Columns><string>Code</string><string>Naam</string></Columns><Items><ArrayOfString><string>1000</string><string>Waardedijk</string></ArrayOfString><ArrayOfString><string>1001</string><string>Witteveen</string></ArrayOfString><ArrayOfString><string>1002</string><string>Bosman</string></ArrayOfString><ArrayOfString><string>1003</string><string>Samkalde</string></ArrayOfString></Items></data></SearchResponse></soap:Body></soap:Envelope>')

        customers = Twinfield::Customer.search("*Bos*")
        expect(customers.length).to eq(4)
        expect(customers[0]).to be_a Twinfield::Customer
        expect(customers.map{|a| a.name}).to include("Waardedijk")

      end

      it "deals with no result" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/finder.asmx")
        .with(body: /\>\<string\>dimtype\<\/string\>\<string\>DEB\<\/string\>/)
        .to_return(body: '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><SearchResponse xmlns="http://www.twinfield.com/"><SearchResult /><data><TotalRows>0</TotalRows><Columns><string>Code</string><string>Naam</string></Columns></data></SearchResponse></soap:Body></soap:Envelope>')

        customers = Twinfield::Customer.search("nonexisting")
        expect(customers.length).to eq(0)
      end

      it "deals with single result" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/finder.asmx")
        .with(body: /\>\<string\>dimtype\<\/string\>\<string\>DEB\<\/string\>/)
        .to_return(body: '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><SearchResponse xmlns="http://www.twinfield.com/"><SearchResult /><data><TotalRows>1</TotalRows><Columns><string>Code</string><string>Naam</string></Columns><Items><ArrayOfString><string>1002</string><string>Bosman</string></ArrayOfString></Items></data></SearchResponse></soap:Body></soap:Envelope>')

        customers = Twinfield::Customer.search("nonexisting")
        expect(customers.length).to eq(1)
        expect(customers[0].name).to eq("Bosman")
      end
    end
  end

  describe "instance methods" do
    describe "#to_h" do
      it "returns a hash without higher order objects" do
        stringified_hash = existing_customer.to_h.to_s
        expect(stringified_hash).not_to match("Twinfield:")
      end
    end
    describe "#to_xml" do
      it "returns returns nokogiri xml" do
        existing_customer.banks << Twinfield::Customer::Bank.new(default: true, accountnumber: 12345678, id: 1)
        recreated_customer = Twinfield::Customer.from_xml(Nokogiri::XML(existing_customer.to_xml))
        expect(recreated_customer.name).to eq(existing_customer.name)
        expect(recreated_customer.financials.ebillmail).to eq(existing_customer.financials.ebillmail)
        expect(recreated_customer.addresses[0].name).to eq(existing_customer.addresses[0].name)
        expect(recreated_customer.banks[0].accountnumber).to eq("12345678")
      end
    end

    describe "#save" do
      it "saves a new record" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
        with(body: /Maarten Brouwers/).
        to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/customer/create_success.xml', __FILE__)))

        customer = Twinfield::Customer.new(name: "Maarten Brouwers", code: "1200")
        customer = customer.save
        expect(customer.name).to eq("Maarten Brouwers")
        expect(customer.uid).to eq("ece29a7f-344f-4e37-b5ca-53e2a468070e")
      end

      it "updates a record" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
        with(body: /Maarten Brouwers/).
        to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/customer/create_success.xml', __FILE__)))

        customer = Twinfield::Customer.new(name: "Maarten Brouwers", code: "1200")
        customer = customer.save
        expect(customer.name).to eq("Maarten Brouwers")
        expect(customer.uid).to eq("ece29a7f-344f-4e37-b5ca-53e2a468070e")
        expect(customer.shortname).to eq("")

        customer.shortname = "murb"

        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
        with(body: /ece29a7f-344f-4e37-b5ca-53e2a468070e/).
        to_return(body: File.read(File.expand_path('../../fixtures/cluster/processxml/customer/update_success.xml', __FILE__)))

        customer = customer.save
        expect(customer.shortname).to eq("murb")
      end
    end
  end
end


