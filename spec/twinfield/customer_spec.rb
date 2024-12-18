require "spec_helper"

describe Twinfield::Customer do
  include SessionStubs
  include FinderStubs
  include ProcessxmlStubs

  before do
    stub_create_session
    stub_cluster_session_wsdl
    stub_select_company
  end

  def stub_customer_ids_request(values)
    stub_request(:post, "https://accounting.twinfield.com/webservices/finder.asmx")
      .with(body: /maxRows>10000<\/ma(.*)><string>dimtype<\/string><string>DEB<\/string>/)
      .to_return(body: '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body>
      <SearchResponse xmlns="http://www.twinfield.com/"><SearchResult /><data><TotalRows>17</TotalRows><Columns><string>Code</string><string>Naam</string></Columns>
      <Items>' + values.map { |k, v| "<ArrayOfString><string>#{k}</string><string>#{v}</string></ArrayOfString>" }.join("") + '
      </Items></data></SearchResponse></soap:Body></soap:Envelope>')
  end

  let(:existing_customer) do
    stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
      .with(body: /<dimtype>DEB<\/dimtype>/)
      .to_return(body: File.read(File.expand_path("../../fixtures/cluster/processxml/customer/read_success.xml", __FILE__)))
    Twinfield::Customer.find(1000)
  end

  describe Twinfield::Customer::Address do
    describe ".to_s" do
      it "returns a simple formattable string of the address" do
        expect(Twinfield::Customer::Address.new(name: "Some Company B.V.", field1: "T.a.v. Jansen", field2: "Berendstraat 12", postcode: "1234AS", city: "Amsterdam", country: "NL").to_s).to eq("Some Company B.V.\nT.a.v. Jansen\nBerendstraat 12\nNL 1234AS Amsterdam")
        expect(Twinfield::Customer::Address.new(name: "Some Company B.V.", field2: "Berendstraat 12", postcode: "1234AS", city: "Amsterdam", country: "NL").to_s).to eq("Some Company B.V.\nBerendstraat 12\nNL 1234AS Amsterdam")
      end
    end
  end

  describe Twinfield::Customer::Financials do
    describe ".to_xml" do
      it "returns a near empty xml when blank" do
        expect(Twinfield::Customer::Financials.new(level: 2).to_xml).to eq("<financials>\n  <level>2</level>\n  <meansofpayment>none</meansofpayment>\n</financials>")
      end
    end

    describe "#meansofpayment" do
      it "returns 'none' by default" do
        expect(Twinfield::Customer::Financials.new.meansofpayment).to eq "none"
      end
    end

    describe "#payavailable" do
      it "returns falsey by default" do
        expect(Twinfield::Customer::Financials.new.payavailable).to be_falsey
      end

      it "can be set to true and changes meansofpayment" do
        new_financials = Twinfield::Customer::Financials.new

        expect(new_financials.meansofpayment).to eq "none"

        new_financials.payavailable = true

        expect(new_financials.payavailable).to be_truthy
        expect(new_financials.meansofpayment).to eq "paymentfile"
      end
    end
  end

  describe "class methods" do
    describe ".find" do
      it "returns a sales invoice" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /<dimtype>DEB<\/dimtype>/)
          .to_return(body: File.read(File.expand_path("../../fixtures/cluster/processxml/customer/read_success.xml", __FILE__)))
        customer = Twinfield::Customer.find(1000)
        expect(customer.name).to eq("Waardedijk")
        expect(customer.financials.childvalidations).to eq("1300")
        expect(customer.addresses[0].default).to eq(true)
        expect(customer.addresses[0].type).to eq("invoice")
        expect(customer.modified).to eq DateTime.new(2021, 10, 13, 20, 30, 53)
      end

      it "deals with an invalid code message" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /<dimtype>DEB<\/dimtype>/)
          .to_return(body: '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><ProcessXmlStringResponse xmlns="http://www.twinfield.com/"><ProcessXmlStringResult>&lt;dimension result="0"&gt;&lt;office name="Heden" shortname=""&gt;NLA002058&lt;/office&gt;&lt;type name="Debiteuren" shortname="Debiteuren"&gt;DEB&lt;/type&gt;&lt;code msgtype="error" msg="De code voldoet niet aan het formaat 1[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]." result="0"&gt;100011&lt;/code&gt;&lt;/dimension&gt;</ProcessXmlStringResult></ProcessXmlStringResponse></soap:Body></soap:Envelope>')
        customer = Twinfield::Customer.find(1000)
        expect(customer).to be_nil
      end
    end

    describe ".new" do
      it "allows to be initialized using a hash" do
        params = {office: "NLA002058",
                  code: "1004",
                  uid: "c6d17557-dc9b-43ca-92a4-ea07a7627984",
                  name: "De Jong",
                  shortname: "",
                  inuse: "true",
                  behaviour: "normal",
                  modified: Time.now,
                  touched: "1",
                  beginperiod: "0",
                  beginyear: "0",
                  endperiod: "0",
                  endyear: "0",
                  website: "",
                  cocnumber: "",
                  vatnumber: "",
                  financials: {matchtype: "customersupplier",
                               accounttype: "inherit",
                               subanalyse: "false",
                               duedays: "10",
                               level: "2",
                               payavailable: "true",
                               meansofpayment: "paymentfile",
                               paycode: "SEPANLDD",
                               ebilling: true,
                               ebillmail: "test@test.nl",
                               substitutewith: "1300",
                               substitutionlevel: "1",
                               relationsreference: "",
                               vattype: "",
                               vatcode: "",
                               vatobligatory: "false",
                               performancetype: "",
                               collectmandate: {signaturedate: Time.now, id: "1004"},
                               collectionschema: "core",
                               childvalidations: "1300"},
                  creditmanagement: {responsibleuser: "", basecreditlimit: "0.00", sendreminder: "true", reminderemail: "", blocked: "false", freetext1: "", freetext2: "", freetext3: "", comment: ""},
                  remittanceadvice: {sendtype: "ToFileManager", sendmail: ""},
                  addresses: [{name: "De Jong", country: "NL", ictcountrycode: "NL", city: "Rotterdam", postcode: "3012 AF", telephone: "010-6874598", telefax: "", email: "", contact: "", field1: "De heer G. de Jong", field2: "Huizerweg 124a", field3: "", field4: "", field5: "", field6: "", type: "invoice", id: "1", default: "true"}],
                  banks: [{address: {name: "", country: "", ictcountrycode: "", city: "", postcode: "", telephone: "", telefax: "", email: "", contact: "", field1: "", field2: "", field3: "", field4: "", field5: "", field6: "", type: nil, id: nil, default: nil},
                           ascription: "De Jong",
                           accountnumber: "",
                           bankname: "",
                           biccode: "",
                           city: "",
                           country: "NL",
                           iban: "NL30TRIO0123456789",
                           natbiccode: "",
                           postcode: "",
                           state: "",
                           id: "1",
                           default: "true"}],
                  status: "active"}
        c = Twinfield::Customer.new(**params)
        expect(c.office).to eq("NLA002058")
        expect(c.code).to eq("1004")
        expect(c.addresses.first.city).to eq("Rotterdam")
        expect(c.financials.collectmandate.id).to eq("1004")
        expect(c.financials.payavailable).to eq("true")
        expect(c.banks.first.iban).to eq("NL30TRIO0123456789")
      end
    end

    describe ".all" do
      it "returns a list of customers" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/finder.asmx")
          .with(body: /><string>dimtype<\/string><string>DEB<\/string>/)
          .to_return(body: '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><SearchResponse xmlns="http://www.twinfield.com/"><SearchResult /><data><TotalRows>17</TotalRows><Columns><string>Code</string><string>Naam</string></Columns><Items><ArrayOfString><string>1000</string><string>Waardedijk</string></ArrayOfString><ArrayOfString><string>1001</string><string>Witteveen</string></ArrayOfString><ArrayOfString><string>1002</string><string>Bosman</string></ArrayOfString><ArrayOfString><string>1003</string><string>Samkalde</string></ArrayOfString></Items></data></SearchResponse></soap:Body></soap:Envelope>')

        customers = Twinfield::Customer.all
        expect(customers.length).to eq(4)
        expect(customers[0]).to be_a Twinfield::Customer
        expect(customers.map { |a| a.name }).to include("Waardedijk")
      end
    end

    describe ".search" do
      it "accepts a search param" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/finder.asmx")
          .with(body: /><string>dimtype<\/string><string>DEB<\/string>/)
          .to_return(body: '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><SearchResponse xmlns="http://www.twinfield.com/"><SearchResult /><data><TotalRows>17</TotalRows><Columns><string>Code</string><string>Naam</string></Columns><Items><ArrayOfString><string>1000</string><string>Waardedijk</string></ArrayOfString><ArrayOfString><string>1001</string><string>Witteveen</string></ArrayOfString><ArrayOfString><string>1002</string><string>Bosman</string></ArrayOfString><ArrayOfString><string>1003</string><string>Samkalde</string></ArrayOfString></Items></data></SearchResponse></soap:Body></soap:Envelope>')

        customers = Twinfield::Customer.search("*Bos*")
        expect(customers.length).to eq(4)
        expect(customers[0]).to be_a Twinfield::Customer
        expect(customers.map { |a| a.name }).to include("Waardedijk")
      end

      it "deals with no result" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/finder.asmx")
          .with(body: /><string>dimtype<\/string><string>DEB<\/string>/)
          .to_return(body: '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><SearchResponse xmlns="http://www.twinfield.com/"><SearchResult /><data><TotalRows>0</TotalRows><Columns><string>Code</string><string>Naam</string></Columns></data></SearchResponse></soap:Body></soap:Envelope>')

        customers = Twinfield::Customer.search("nonexisting")
        expect(customers.length).to eq(0)
      end

      it "deals with single result" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/finder.asmx")
          .with(body: /><string>dimtype<\/string><string>DEB<\/string>/)
          .to_return(body: '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><SearchResponse xmlns="http://www.twinfield.com/"><SearchResult /><data><TotalRows>1</TotalRows><Columns><string>Code</string><string>Naam</string></Columns><Items><ArrayOfString><string>1002</string><string>Bosman</string></ArrayOfString></Items></data></SearchResponse></soap:Body></soap:Envelope>')

        customers = Twinfield::Customer.search("nonexisting")
        expect(customers.length).to eq(1)
        expect(customers[0].name).to eq("Bosman")
      end
    end

    describe ".next_unused_twinfield_customer_code" do
      it "returns a new code" do
        stub_customer_ids_request({"1000": "Waardewijk", "1001": "Witteveen", "1002": "Bosman", "1003": "Samkalde"})
        expect(Twinfield::Customer.next_unused_twinfield_customer_code).to eq("1004")
      end

      it "returns a new code" do
        stub_customer_ids_request({"1000": "Waardewijk", "1001": "Witteveen", "1002": "Bosman", "9003": "Company", "1003": "Samkalde"})
        expect(Twinfield::Customer.next_unused_twinfield_customer_code).to eq("9004")
      end

      it "returns a new code within a given range" do
        stub_customer_ids_request({"1000": "Waardewijk", "1001": "Witteveen", "1002": "Bosman", "9003": "Company", "1003": "Samkalde"})
        expect(Twinfield::Customer.next_unused_twinfield_customer_code(1000..2000)).to eq("1004")
      end

      it "returns a new code even when nothing exists in that range" do
        stub_customer_ids_request({"1000": "Waardewijk", "1001": "Witteveen", "1002": "Bosman", "9003": "Company", "1003": "Samkalde"})
        expect(Twinfield::Customer.next_unused_twinfield_customer_code(10000..20000)).to eq("10000")
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
        date = Time.now.to_date
        collectmandate_id = "4c3f01c582814bc78a8858453392899e"
        existing_customer.banks << Twinfield::Customer::Bank.new(default: true, accountnumber: 12345678, id: 1)
        existing_customer.financials.collectmandate = Twinfield::Customer::CollectMandate.new(signaturedate: date, id: collectmandate_id)

        customer_xml = existing_customer.to_xml

        recreated_customer = Twinfield::Customer.from_xml(customer_xml)

        expect(recreated_customer.name).to eq(existing_customer.name)
        expect(recreated_customer.financials.ebillmail).to eq(existing_customer.financials.ebillmail)
        expect(recreated_customer.addresses[0].name).to eq(existing_customer.addresses[0].name)
        expect(recreated_customer.banks[0].accountnumber).to eq("12345678")
        expect(recreated_customer.financials.collectmandate.signaturedate).to eq(date)
      end

      it "Twinfield::Customer::Bank doesn't ad an id attribute if id is nil" do
        b = Twinfield::Customer::Bank.new(default: true, iban: 12345678)
        expect(b.to_xml).to match("default=\"true\"")
        expect(b.to_xml).not_to match("id=\"\"")
      end

      it "Twinfield::Customer::CollectMandate.to_xml" do
        date = Time.now.to_date
        collectmandate_id = "4c3f01c582814bc78a8858453392899e"

        cm = Twinfield::Customer::CollectMandate.new(signaturedate: date, id: collectmandate_id)
        expect(cm.to_xml).to match("<id>4c3f01c582814bc78a8858453392899e</id>")
      end
    end

    describe "#transactions" do
      it "returns Twinfield::Browse::Transaction::Customers" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .to_return(body: File.read(File.expand_path("../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        customer = Twinfield::Customer.new(name: "Maarten Brouwers", code: "1003")
        transaction = customer.transactions.first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::Customer)
        expect(transaction.value).to eql(2200.0)
      end

      it "allows for filtering" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /<from>VRFK<\/from>/)
          .to_return(body: File.read(File.expand_path("../../fixtures/cluster/processxml/columns/sales_transactions.xml", __FILE__)))

        customer = Twinfield::Customer.new(name: "Maarten Brouwers", code: "1003")
        transaction = customer.transactions(code: "VRFK").first

        expect(transaction).to be_a(Twinfield::Browse::Transaction::Customer)
        expect(transaction.value).to eql(2200.0)
      end
    end

    describe "#save" do
      it "saves a new record" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /Maarten Brouwers/)
          .to_return(body: File.read(File.expand_path("../../fixtures/cluster/processxml/customer/create_success.xml", __FILE__)))

        customer = Twinfield::Customer.new(name: "Maarten Brouwers", code: "1200")
        customer = customer.save
        expect(customer.name).to eq("Maarten Brouwers")
        expect(customer.uid).to eq("ece29a7f-344f-4e37-b5ca-53e2a468070e")
      end

      it "updates a record" do
        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /Maarten Brouwers/)
          .to_return(body: File.read(File.expand_path("../../fixtures/cluster/processxml/customer/create_success.xml", __FILE__)))

        customer = Twinfield::Customer.new(name: "Maarten Brouwers", code: "1200")
        customer = customer.save
        expect(customer.name).to eq("Maarten Brouwers")
        expect(customer.uid).to eq("ece29a7f-344f-4e37-b5ca-53e2a468070e")
        expect(customer.shortname).to eq("")

        customer.shortname = "murb"

        stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx")
          .with(body: /ece29a7f-344f-4e37-b5ca-53e2a468070e/)
          .to_return(body: File.read(File.expand_path("../../fixtures/cluster/processxml/customer/update_success.xml", __FILE__)))

        customer = customer.save
        expect(customer.shortname).to eq("murb")
      end
    end
  end
end
