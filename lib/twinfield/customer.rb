module Twinfield
  class Customer < Twinfield::AbstractModel
    extend Twinfield::Helpers::Parsers

    class CollectMandate
      extend Twinfield::Helpers::Parsers

      attr_accessor :signaturedate, :id

      def initialize(signaturedate: nil, id: nil)
        @signaturedate = signaturedate
        @id = id
      end

      def to_h
        {signaturedate: signaturedate, id: id}
      end
      alias_method :to_hash, :to_h

      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          xml.collectmandate do
            xml.id id
            xml.signaturedate signaturedate&.strftime("%Y%m%d")
          end
        end.doc.root.to_xml
      end

      def self.from_xml(nokogiri)
        obj = self.new
        obj.signaturedate = parse_date(nokogiri.css("signaturedate").text)
        obj.id = nokogiri.css("id").text
        obj
      end
    end

    class RemittanceAdvice
      attr_accessor :sendtype, :sendmail

      def initialize(sendtype: nil, sendmail: nil)
        @sendtype = sendtype
        @sendmail = sendmail
      end

      def to_h
        {sendtype: sendtype, sendmail: sendmail}
      end
      alias_method :to_hash, :to_h

      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          xml.remittanceadvice do
            xml.sendtype sendtype
            xml.sendmail sendmail
          end
        end.doc.root.to_xml
      end

      def self.from_xml(nokogiri)
        obj = self.new
        obj.sendtype = nokogiri.css("sendtype").text
        obj.sendmail = nokogiri.css("sendmail").text
        obj
      end
    end

    class Bank
      attr_accessor :ascription, :accountnumber, :address, :bankname, :biccode, :city, :country, :iban, :natbiccode, :postcode, :state, :id, :default

      def initialize(ascription: nil, accountnumber: nil, address: nil, bankname: nil, biccode: nil, city: nil, country: nil, iban: nil, natbiccode: nil, postcode: nil, state: nil, id: nil, default: nil)
        @ascription= ascription
        @accountnumber= accountnumber
        @address= address.is_a?(Hash) ? Address.new(**address) : address
        @bankname= bankname
        @biccode= biccode
        @city= city
        @country= country
        @iban= iban
        @natbiccode= natbiccode
        @postcode= postcode
        @state= state
        @default= ["true",true,1,"1"].include?(default)
        @id= id
      end

      def to_h
        {
          address: address.to_h,
          ascription: ascription,
          accountnumber: accountnumber,
          bankname: bankname,
          biccode: biccode,
          city: city,
          country: country,
          iban: iban,
          natbiccode: natbiccode,
          postcode: postcode,
          state: state,
          id: id,
          default: default
        }
      end
      alias_method :to_hash, :to_h

      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          attributes = {default: default}
          attributes[:id] = id if id

          xml.bank(attributes) do
            xml.ascription ascription
            xml.accountnumber accountnumber
            xml.address address
            xml.bankname bankname
            xml.biccode biccode
            xml.city city
            xml.country country
            xml.iban iban
            xml.natbiccode natbiccode
            xml.postcode postcode
            xml.state state
          end
        end.doc.root.to_xml
      end

      def self.from_xml(nokogiri_xml)
        obj = self.new(id: nokogiri_xml.attributes["id"].text, default: nokogiri_xml.attributes["default"].text)
        obj.ascription = nokogiri_xml.css("ascription").text
        obj.accountnumber = nokogiri_xml.css("accountnumber").text
        obj.address = Address.from_xml(nokogiri_xml.css("address")[0]) if nokogiri_xml.css("address")[0].children.count > 0
        obj.bankname = nokogiri_xml.css("bankname").text
        obj.biccode = nokogiri_xml.css("biccode").text
        obj.city = nokogiri_xml.css("city").text
        obj.country = nokogiri_xml.css("country").text
        obj.iban = nokogiri_xml.css("iban").text
        obj.natbiccode = nokogiri_xml.css("natbiccode").text
        obj.postcode = nokogiri_xml.css("postcode").text
        obj.state = nokogiri_xml.css("state").text
        obj
      end
    end

    class Financials
      extend Twinfield::Helpers::Parsers

      attr_accessor :matchtype, :accounttype, :subanalyse, :duedays, :level, :payavailable, :meansofpayment, :paycode, :ebilling, :ebillmail, :substitutewith, :substitutionlevel, :relationsreference, :vattype, :vatcode, :vatobligatory, :performancetype, :collectmandate, :collectionschema, :childvalidations

      def initialize(matchtype: nil, accounttype: nil, subanalyse: nil, duedays: nil, level: nil, payavailable: nil, meansofpayment: nil, paycode: nil, ebilling: false, ebillmail: nil, substitutewith: nil, substitutionlevel: nil, relationsreference: nil, vattype: nil, vatcode: nil, vatobligatory: nil, performancetype: nil, collectmandate: nil, collectionschema: nil, childvalidations: nil)
        @matchtype = matchtype
        @accounttype = accounttype
        @subanalyse = subanalyse
        @duedays = duedays
        @level = level
        @payavailable = payavailable # Direct Debit / Automatische incasso
        @meansofpayment = meansofpayment
        @paycode = paycode
        @ebilling = ebilling
        @ebillmail = ebillmail
        @substitutewith = substitutewith
        @substitutionlevel = substitutionlevel
        @relationsreference = relationsreference # not in use
        @vattype = vattype # not in use
        @vatcode = vatcode
        @vatobligatory = vatobligatory
        @performancetype = performancetype
        @collectmandate = collectmandate.is_a?(Hash) ? Twinfield::Customer::CollectMandate.new(**collectmandate) : collectmandate
        @collectionschema = collectionschema
        @childvalidations = childvalidations
      end

      def meansofpayment
        @meansofpayment || (payavailable ? "paymentfile" : "none")
      end

      def to_h
        {
          matchtype: matchtype,
          accounttype: accounttype,
          subanalyse: subanalyse,
          duedays: duedays,
          level: level,
          payavailable: payavailable,
          meansofpayment: meansofpayment,
          paycode: paycode,
          ebilling: ebilling,
          ebillmail: ebillmail,
          substitutewith: substitutewith,
          substitutionlevel: substitutionlevel,
          relationsreference: relationsreference,
          vattype: vattype,
          vatcode: vatcode,
          vatobligatory: vatobligatory,
          performancetype: performancetype,
          collectmandate: collectmandate&.to_h,
          collectionschema: collectionschema,
          childvalidations: childvalidations
        }
      end
      alias_method :to_hash, :to_h

      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          xml.financials do
            xml.matchtype matchtype if matchtype
            xml.accounttype accounttype if accounttype
            xml.subanalyse subanalyse if subanalyse
            xml.duedays duedays if duedays
            xml.level level if level
            xml.payavailable payavailable if payavailable
            xml.meansofpayment meansofpayment if meansofpayment
            xml.paycode paycode if paycode
            xml.ebilling ebilling if ebilling
            xml.ebillmail ebillmail if ebillmail
            xml.substitutewith substitutewith if substitutewith
            xml.substitutionlevel substitutionlevel if substitutionlevel
            xml.relationsreference relationsreference if relationsreference
            xml.vattype vattype if vattype
            xml.vatcode vatcode if vatcode
            xml.vatobligatory vatobligatory if vatobligatory
            xml.performancetype performancetype if performancetype
            xml << collectmandate.to_xml if collectmandate
            xml.collectionschema collectionschema if collectionschema
          end
        end.doc.root.to_xml
      end

      def self.from_xml(nokogiri)
        obj = self.new
        obj.matchtype = nokogiri.css("matchtype").text
        obj.accounttype = nokogiri.css("accounttype").text
        obj.subanalyse = nokogiri.css("subanalyse").text
        obj.duedays = nokogiri.css("duedays").text
        obj.level = nokogiri.css("level").text
        obj.payavailable = nokogiri.css("payavailable").text
        obj.meansofpayment = nokogiri.css("meansofpayment").text
        obj.paycode = nokogiri.css("paycode").text
        obj.ebilling = nokogiri.css("ebilling").text == "true" ? true : false
        obj.ebillmail = nokogiri.css("ebillmail").text
        obj.substitutewith = nokogiri.css("substitutewith").text
        obj.substitutionlevel = nokogiri.css("substitutionlevel").text
        obj.relationsreference = nokogiri.css("relationsreference").text
        obj.vattype = nokogiri.css("vattype").text
        obj.vatcode = nokogiri.css("vatcode").text
        obj.vatobligatory = nokogiri.css("vatobligatory").text
        obj.performancetype = nokogiri.css("performancetype").text
        obj.collectmandate = CollectMandate.from_xml(nokogiri.css("collectmandate"))
        obj.collectionschema = nokogiri.css("collectionschema").text
        obj.childvalidations = nokogiri.css("childvalidations").text&.strip
        obj
      end
    end

    class CreditManagement
      attr_accessor :responsibleuser, :basecreditlimit, :sendreminder, :reminderemail, :blocked, :freetext1, :freetext2, :freetext3, :comment

      def to_h
        {
          responsibleuser: responsibleuser,
          basecreditlimit: basecreditlimit,
          sendreminder: sendreminder,
          reminderemail: reminderemail,
          blocked: blocked,
          freetext1: freetext1,
          freetext2: freetext2,
          freetext3: freetext3,
          comment: comment
        }
      end
      alias_method :to_hash, :to_h

      def initialize(responsibleuser: nil, basecreditlimit: nil, sendreminder: nil, reminderemail: nil, blocked: nil, freetext1: nil, freetext2: nil, freetext3: nil, comment: nil)
        @responsibleuser = responsibleuser
        @basecreditlimit = basecreditlimit
        @sendreminder = sendreminder
        @reminderemail = reminderemail
        @blocked = blocked
        @freetext1 = freetext1
        @freetext2 = freetext2
        @freetext3 = freetext3
        @comment = comment
      end

      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          xml.creditmanagement do
            xml.responsibleuser responsibleuser
            xml.basecreditlimit basecreditlimit
            xml.sendreminder sendreminder
            xml.reminderemail reminderemail
            xml.blocked blocked
            xml.freetext1 freetext1
            xml.freetext2 freetext2
            xml.freetext3 freetext3
            xml.comment comment
          end
        end.doc.root.to_xml
      end

      def self.from_xml(nokogiri)
        obj = self.new
        obj.responsibleuser= nokogiri.css("responsibleuser").text
        obj.basecreditlimit= nokogiri.css("basecreditlimit").text
        obj.sendreminder= nokogiri.css("sendreminder").text
        obj.reminderemail= nokogiri.css("reminderemail").text
        obj.blocked= nokogiri.css("blocked").text
        obj.freetext1= nokogiri.css("freetext1").text
        obj.freetext2= nokogiri.css("freetext2").text
        obj.freetext3= nokogiri.css("freetext3").text
        obj.comment= nokogiri.css("comment").text
        obj
      end
    end

    class Address
      attr_accessor :name, :country, :ictcountrycode, :city, :postcode, :telephone, :telefax, :email, :contact, :field1, :field2, :field3, :field4, :field5, :field6, :type, :default, :id

      def initialize(name: , country: nil, ictcountrycode: nil, city: nil, postcode: nil, telephone: nil, telefax: nil, email: nil, contact: nil, field1: nil, field2: nil, field3: nil, field4: nil, field5: nil, field6: nil, id: nil, type: nil, default: nil)
        @name= name
        @country= country
        @ictcountrycode= ictcountrycode
        @city= city
        @postcode= postcode
        @telephone= telephone
        @telefax= telefax
        @email= email
        @contact= contact
        @field1= field1
        @field2= field2
        @field3= field3
        @field4= field4
        @field5= field5
        @field6= field6
        @id = id
        @type = type
        @default = ["true",true,1,"1"].include?(default)
      end

      def to_h
        {
          name: name,
          country: country,
          ictcountrycode: ictcountrycode,
          city: city,
          postcode: postcode,
          telephone: telephone,
          telefax: telefax,
          email: email,
          contact: contact,
          field1: field1,
          field2: field2,
          field3: field3,
          field4: field4,
          field5: field5,
          field6: field6,
          type: type,
          id: id,
          default: default
        }
      end
      alias_method :to_hash, :to_h

      def to_s
        "#{field1}\n#{field2}\n#{country} #{postcode} #{city}"
      end

      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          xml.address(id: @id, type: @type, default: @default) do
            xml.name name
            xml.country country
            xml.ictcountrycode ictcountrycode
            xml.city city
            xml.postcode postcode
            xml.telephone telephone
            xml.telefax telefax
            xml.email email
            xml.contact contact
            xml.field1 field1
            xml.field2 field2
            xml.field3 field3
            xml.field4 field4
            xml.field5 field5
            xml.field6 field6
          end
        end.doc.root.to_xml
      end

      def self.from_xml nokogiri
        obj = self.new(id: nokogiri.attributes["id"]&.text, name: nokogiri.css("name")&.text, default: nokogiri.attributes["default"]&.text)
        obj.country= nokogiri.css("country").text
        obj.type= nokogiri.attributes["type"]&.text
        obj.ictcountrycode= nokogiri.css("ictcountrycode")&.text
        obj.city= nokogiri.css("city")&.text
        obj.postcode= nokogiri.css("postcode")&.text
        obj.telephone= nokogiri.css("telephone")&.text
        obj.telefax= nokogiri.css("telefax")&.text
        obj.email= nokogiri.css("email")&.text
        obj.contact= nokogiri.css("contact")&.text
        obj.field1= nokogiri.css("field1")&.text
        obj.field2= nokogiri.css("field2")&.text
        obj.field3= nokogiri.css("field3")&.text
        obj.field4= nokogiri.css("field4")&.text
        obj.field5= nokogiri.css("field5")&.text
        obj.field6= nokogiri.css("field6")&.text
        obj
      end
    end

    attr_accessor :office, :code, :uid, :name, :shortname, :inuse, :behaviour, :modified, :touched, :beginperiod, :beginyear, :endperiod, :endyear, :website, :cocnumber, :vatnumber, :financials, :creditmanagement, :remittanceadvice, :addresses, :banks, :status

    def initialize(office: nil, code: nil, uid: nil, name: nil, shortname: nil, inuse: nil, behaviour: nil, modified: nil, touched: nil, beginperiod: nil, beginyear: nil, endperiod: nil, endyear: nil, website: nil, cocnumber: nil, vatnumber: nil, financials: nil, creditmanagement: nil, remittanceadvice: nil, addresses: nil, banks: nil, status: :active)
      @office= office || Twinfield.configuration.company
      @status= status
      @code= code
      @uid= uid
      @name= name
      @shortname= shortname
      @inuse= inuse
      @behaviour= behaviour
      @modified= modified
      @touched= touched
      @beginperiod= beginperiod
      @beginyear= beginyear
      @endperiod= endperiod
      @endyear= endyear
      @website= website
      @cocnumber= cocnumber
      @vatnumber= vatnumber
      @financials= financials.is_a?(Hash) ? Financials.new(**financials) : financials
      @creditmanagement= creditmanagement.is_a?(Hash) ? CreditManagement.new(**creditmanagement) : creditmanagement
      @remittanceadvice= remittanceadvice.is_a?(Hash) ? RemittanceAdvice.new(**remittanceadvice) : remittanceadvice
      @addresses= (addresses || []).map{|a| a.is_a?(Hash) ? Address.new(**a) : a}
      @banks= (banks || []).map{|a| a.is_a?(Hash) ? Bank.new(**a) : a}
    end

    def to_h
      {
        office: office,
        code: code,
        uid: uid,
        name: name,
        shortname: shortname,
        inuse: inuse,
        behaviour: behaviour,
        modified: modified,
        touched: touched,
        beginperiod: beginperiod,
        beginyear: beginyear,
        endperiod: endperiod,
        endyear: endyear,
        website: website,
        cocnumber: cocnumber,
        vatnumber: vatnumber,
        financials: financials.to_h,
        creditmanagement: creditmanagement.to_h,
        remittanceadvice: remittanceadvice.to_h,
        addresses: addresses.map(&:to_h),
        banks: banks.map(&:to_h),
        status: status
      }
    end
    alias_method :to_hash, :to_h

    def to_xml
      Nokogiri::XML::Builder.new do |xml|
        xml.dimension(status: status) do
          xml.office office
          xml.type "DEB"
          xml.code code
          xml.uid uid if uid
          xml.name name
          xml.shortname shortname
          # xml.behaviour behaviour #temporarily disable
          xml.beginperiod beginperiod if beginperiod
          xml.beginyear beginyear if beginyear
          xml.endperiod endperiod if endperiod
          xml.endyear endyear if endyear
          xml.website website
          xml << financials&.to_xml
          xml << creditmanagement&.to_xml
          xml << remittanceadvice&.to_xml
          xml.addresses do
            addresses.each do |line|
              xml << line.to_xml
            end
          end
          xml.banks do
            banks.each do |line|
              xml << line.to_xml
            end
          end
        end
      end.doc.root.to_xml
    end

    def save
      response = Twinfield::Api::Process.request { self.to_xml }

      xml = Nokogiri::XML(response.body[:process_xml_string_response][:process_xml_string_result])

      if xml.at_css("dimension").attributes["result"].value == "1"
        self.class.from_xml(xml)
      else
        raise Twinfield::Create::Error.new(xml.css("[msg]").map{ |x| x.attributes["msg"].value }.join(" "), object: self)
      end
    end

    def destroy
      self.status = :deleted
      self.save
    end
    alias_method :delete, :destroy

    def transactions(filter_hash = {})
      Twinfield::Browse::Transaction::Customer.where(**{customer_code: code}.merge(filter_hash))
    end

    def load
      Customer.find(code)
    end

    class << self
      # @return Array<Twinfield::Customer>
      def all
        self.search
      end

      # helper method that calculates the next unused code
      # @return String
      def next_unused_twinfield_customer_code
        latest = Twinfield::Customer.all.map(&:code).map(&:to_i).sort.last
        latest += 1
        raise "invalid new customer code" if latest == 1
        latest.to_s
      end

      def search text="*"
        text = "*#{text}*" unless text.match?(/[?*]/)
        options = {
          dimtype: "DEB",
          office: Twinfield.configuration.company,
          pattern: text,
          max_rows: 10000
        }
        response = Twinfield::Api::Finder.request("DIM", options)
        if response.body[:search_response][:data][:total_rows].to_i == 1
          resp = response.body[:search_response][:data][:items][:array_of_string][:string]
          return [Customer.new(name: resp[1], code: resp[0])]
        elsif response.body[:search_response][:data][:total_rows].to_i > 1
          response.body[:search_response][:data][:items][:array_of_string]
            .map{|item| Customer.new(name: item[:string][1], code: item[:string][0])}
        else
          return []
        end
      end

      def find(customercode)
        options = {office: Twinfield.configuration.company, code: customercode, dimtype: "DEB"}
        customer_xml = Twinfield::Api::Process.read(:dimensions, options)
        self.from_xml(customer_xml)
      end

      def from_xml(nokogiri_or_string)
        nokogiri = nokogiri_or_string.is_a?(Nokogiri::XML::Document) ? nokogiri_or_string : Nokogiri::XML(nokogiri_or_string)

        obj = self.new(shortname: nokogiri.css("dimension > shortname").text, name: nokogiri.css("dimension > name").text, code: nokogiri.css("dimension > code").text)
        obj.status= nokogiri.css("dimension")[0].attributes["status"].text
        obj.office= nokogiri.css("dimension > office").text
        obj.uid= nokogiri.css("dimension > uid").text
        obj.inuse= nokogiri.css("dimension > inuse").text
        obj.behaviour= nokogiri.css("dimension > behaviour").text
        obj.modified= parse_datetime(nokogiri.css("dimension > modified").text)
        obj.touched= nokogiri.css("dimension > touched").text
        obj.beginperiod= nokogiri.css("dimension > beginperiod").text
        obj.beginyear= nokogiri.css("dimension > beginyear").text
        obj.endperiod= nokogiri.css("dimension > endperiod").text
        obj.endyear= nokogiri.css("dimension > endyear").text
        obj.website= nokogiri.css("dimension > website").text
        obj.cocnumber= nokogiri.css("dimension > cocnumber").text
        obj.vatnumber= nokogiri.css("dimension > vatnumber").text
        obj.financials= Financials.from_xml(nokogiri.css("dimension > financials")[0])
        obj.creditmanagement= CreditManagement.from_xml(nokogiri.css("dimension > creditmanagement")[0]) if nokogiri.css("dimension > creditmanagement")[0]
        obj.remittanceadvice= RemittanceAdvice.from_xml(nokogiri.css("dimension > remittanceadvice")[0]) if nokogiri.css("dimension > remittanceadvice")[0]
        obj.addresses= nokogiri.css("dimension > addresses > address").map{ |xml_fragment| Address.from_xml(xml_fragment) }
        obj.banks= nokogiri.css("dimension > banks > bank").map{ |xml_fragment| Bank.from_xml(xml_fragment) }
        obj
      end
    end
  end
end