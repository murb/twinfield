module Twinfield
  class Customer < Twinfield::AbstractModel
    class CollectMandate
      attr_accessor :signaturedate, :id

      def initialize(signaturedate: nil, id: nil)
        @signaturedate = signaturedate
        @id = id
      end

      def self.from_xml(nokogiri)
        obj = self.new
        obj.signaturedate = nokogiri.css("signaturedate").text()
        obj.id = nokogiri.css("id").text()
        obj
      end
    end

    class Bank
      attr_accessor :ascription, :accountnumber, :address, :bankname, :biccode, :city, :country, :iban, :natbiccode, :postcode, :state

      def initialize(ascription: nil, accountnumber: nil, address: nil, bankname: nil, biccode: nil, city: nil, country: nil, iban: nil, natbiccode: nil, postcode: nil, state: nil)
        @ascription= ascription
        @accountnumber= accountnumber
        @address= address
        @bankname= bankname
        @biccode= biccode
        @city= city
        @country= country
        @iban= iban
        @natbiccode= natbiccode
        @postcode= postcode
        @state= state
      end

      def self.from_xml(nokogiri_xml)
        obj = self.new
        obj.ascription = nokogiri_xml.css("ascription").text()
        obj.accountnumber = nokogiri_xml.css("accountnumber").text()
        obj.address = Address.from_xml(nokogiri_xml.css("address"))
        obj.bankname = nokogiri_xml.css("bankname").text()
        obj.biccode = nokogiri_xml.css("biccode").text()
        obj.city = nokogiri_xml.css("city").text()
        obj.country = nokogiri_xml.css("country").text()
        obj.iban = nokogiri_xml.css("iban").text()
        obj.natbiccode = nokogiri_xml.css("natbiccode").text()
        obj.postcode = nokogiri_xml.css("postcode").text()
        obj.state = nokogiri_xml.css("state").text()
        obj
      end
    end

    class Financials
      attr_accessor :matchtype, :accounttype, :subanalyse, :duedays, :level, :payavailable, :meansofpayment, :paycode, :ebilling, :ebillmail, :substitutewith, :substitutionlevel, :relationsreference, :vattype, :vatcode, :vatobligatory, :performancetype, :collectmandate, :collectionschema, :childvalidations

      def initialize(matchtype: nil, accounttype: nil, subanalyse: nil, duedays: nil, level: nil, payavailable: nil, meansofpayment: nil, paycode: nil, ebilling: nil, ebillmail: nil, substitutewith: nil, substitutionlevel: nil, relationsreference: nil, vattype: nil, vatcode: nil, vatobligatory: nil, performancetype: nil, collectmandate: nil, collectionschema: nil, childvalidations: nil)
        @matchtype = matchtype
        @accounttype = accounttype
        @subanalyse = subanalyse
        @duedays = duedays
        @level = level
        @payavailable = payavailable
        @meansofpayment = meansofpayment
        @paycode = paycode
        @ebilling = ebilling
        @ebillmail = ebillmail
        @substitutewith = substitutewith
        @substitutionlevel = substitutionlevel
        @relationsreference = relationsreference
        @vattype = vattype
        @vatcode = vatcode
        @vatobligatory = vatobligatory
        @performancetype = performancetype
        @collectmandate = collectmandate
        @collectionschema = collectionschema
        @childvalidations = childvalidations
      end

      def self.from_xml(nokogiri)
        obj = self.new
        obj.matchtype = nokogiri.css("matchtype").text()
        obj.accounttype = nokogiri.css("accounttype").text()
        obj.subanalyse = nokogiri.css("subanalyse").text()
        obj.duedays = nokogiri.css("duedays").text()
        obj.level = nokogiri.css("level").text()
        obj.payavailable = nokogiri.css("payavailable").text()
        obj.meansofpayment = nokogiri.css("meansofpayment").text()
        obj.paycode = nokogiri.css("paycode").text()
        obj.ebilling = nokogiri.css("ebilling").text()
        obj.ebillmail = nokogiri.css("ebillmail").text()
        obj.substitutewith = nokogiri.css("substitutewith").text()
        obj.substitutionlevel = nokogiri.css("substitutionlevel").text()
        obj.relationsreference = nokogiri.css("relationsreference").text()
        obj.vattype = nokogiri.css("vattype").text()
        obj.vatcode = nokogiri.css("vatcode").text()
        obj.vatobligatory = nokogiri.css("vatobligatory").text()
        obj.performancetype = nokogiri.css("performancetype").text()
        obj.collectmandate = CollectMandate.from_xml(nokogiri.css("collectmandate"))
        obj.collectionschema = nokogiri.css("collectionschema").text()
        obj.childvalidations = nokogiri.css("childvalidations").text()
        obj
      end
    end

    class CreditManagement
      attr_accessor :responsibleuser, :basecreditlimit, :sendreminder, :reminderemail, :blocked, :freetext1, :freetext2, :freetext3, :comment

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

      def self.from_xml(nokogiri)
        obj = self.new
        obj.responsibleuser= nokogiri.css("responsibleuser").text()
        obj.basecreditlimit= nokogiri.css("basecreditlimit").text()
        obj.sendreminder= nokogiri.css("sendreminder").text()
        obj.reminderemail= nokogiri.css("reminderemail").text()
        obj.blocked= nokogiri.css("blocked").text()
        obj.freetext1= nokogiri.css("freetext1").text()
        obj.freetext2= nokogiri.css("freetext2").text()
        obj.freetext3= nokogiri.css("freetext3").text()
        obj.comment= nokogiri.css("comment").text()
        obj
      end
    end

    class Address
      attr_accessor :name, :country, :ictcountrycode, :city, :postcode, :telephone, :telefax, :email, :contact, :field1, :field2, :field3, :field4, :field5, :field6

      def initialize(name: nil, country: nil, ictcountrycode: nil, city: nil, postcode: nil, telephone: nil, telefax: nil, email: nil, contact: nil, field1: nil, field2: nil, field3: nil, field4: nil, field5: nil, field6: nil)
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
      end

      def self.from_xml nokogiri
        obj = self.new
        obj.name= nokogiri.css("name").text()
        obj.country= nokogiri.css("country").text()
        obj.ictcountrycode= nokogiri.css("ictcountrycode").text()
        obj.city= nokogiri.css("city").text()
        obj.postcode= nokogiri.css("postcode").text()
        obj.telephone= nokogiri.css("telephone").text()
        obj.telefax= nokogiri.css("telefax").text()
        obj.email= nokogiri.css("email").text()
        obj.contact= nokogiri.css("contact").text()
        obj.field1= nokogiri.css("field1").text()
        obj.field2= nokogiri.css("field2").text()
        obj.field3= nokogiri.css("field3").text()
        obj.field4= nokogiri.css("field4").text()
        obj.field5= nokogiri.css("field5").text()
        obj.field6= nokogiri.css("field6").text()
        obj
      end
    end

    attr_accessor :office, :type, :code, :uid, :name, :shortname, :inuse, :behaviour, :modified, :touched, :beginperiod, :beginyear, :endperiod, :endyear, :website, :cocnumber, :vatnumber, :editdimensionname, :financials, :creditmanagement, :remittanceadvice, :addresses, :banks

    def intialize( office: nil, type: nil, code: nil, uid: nil, name: nil, shortname: nil, inuse: nil, behaviour: nil, modified: nil, touched: nil, beginperiod: nil, beginyear: nil, endperiod: nil, endyear: nil, website: nil, cocnumber: nil, vatnumber: nil, editdimensionname: nil, financials: nil, creditmanagement: nil, remittanceadvice: nil, addresses: nil, banks: nil)
      @office= office
      @type= type
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
      @editdimensionname= editdimensionname
      @financials= financials
      @creditmanagement= creditmanagement
      @remittanceadvice= remittanceadvice
      @addresses= addresses || []
      @banks= banks || []
    end

    class << self
      def find(customercode)
        options = {office: Twinfield.configuration.company, code: customercode, dimtype: "DEB"}
        customer_xml = Twinfield::Api::Process.read(:dimensions, options)
        self.from_xml(customer_xml)
      end

      def from_xml(nokogiri)
        obj = self.new
        obj.office= nokogiri.css("dimension > office").text()
        obj.type= nokogiri.css("dimension > type").text()
        obj.code= nokogiri.css("dimension > code").text()
        obj.uid= nokogiri.css("dimension > uid").text()
        obj.name= nokogiri.css("dimension > name").text()
        obj.shortname= nokogiri.css("dimension > shortname").text()
        obj.inuse= nokogiri.css("dimension > inuse").text()
        obj.behaviour= nokogiri.css("dimension > behaviour").text()
        obj.modified= nokogiri.css("dimension > modified").text()
        obj.touched= nokogiri.css("dimension > touched").text()
        obj.beginperiod= nokogiri.css("dimension > beginperiod").text()
        obj.beginyear= nokogiri.css("dimension > beginyear").text()
        obj.endperiod= nokogiri.css("dimension > endperiod").text()
        obj.endyear= nokogiri.css("dimension > endyear").text()
        obj.website= nokogiri.css("dimension > website").text()
        obj.cocnumber= nokogiri.css("dimension > cocnumber").text()
        obj.vatnumber= nokogiri.css("dimension > vatnumber").text()
        obj.editdimensionname= nokogiri.css("dimension > editdimensionname").text()
        obj.financials= Financials.from_xml(nokogiri.css("dimension > financials")[0])
        obj.creditmanagement= CreditManagement.from_xml(nokogiri.css("dimension > creditmanagement")[0])
        obj.remittanceadvice= nokogiri.css("dimension > remittanceadvice").text()
        obj.addresses= nokogiri.css("dimension > addresses address").map{ |xml_fragment| Address.from_xml(xml_fragment) }
        obj
      end
    end
  end
end