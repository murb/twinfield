module SessionStubs
  def stub_create_session username: "username" , password: "password" , organisation: "organisation", response: "Ok"
    stub_request(:post, "https://login.twinfield.com/webservices/session.asmx").
      with(
        body: /<tns:user>#{username}<\/tns:user><tns:password>#{password}<\/tns:password><tns:organisation>#{organisation}<\/tns:organisation><\/tns:Logon>/,
        headers: {
          Soapaction: '"http://www.twinfield.com/Logon"',

        },

      ).to_return(status: 200, body: "<env:Envelope><env:Header><Header><SessionId>session_id</SessionId></Header></env:Header><env:Body><LogonResponse><LogonResult>#{response}</LogonResult><Cluster>https://accounting.twinfield.com</Cluster></LogonResponse></env:Body></env:Envelope>")
  end

  def stub_cluster_session_wsdl
    stub_request(:get, "https://accounting.twinfield.com/webservices/session.asmx?wsdl").
      to_return(status: 200, body: File.read(File.expand_path('../../../wsdls/accounting/session.wsdl', __FILE__)))
  end

  def stub_select_company company: "company"
    stub_request(:post, "https://accounting.twinfield.com/webservices/session.asmx").
             with(
               body: /<soap:Body><SelectCompany xmlns="http:\/\/www.twinfield.com\/\"><company>#{company}<\/company><\/SelectCompany><\/soap:Body>/,
               headers:{
           	  'Soapaction'=>'"http://www.twinfield.com/SelectCompany"',
               }
            ).
             to_return(status: 200, body: "", headers: {})
  end
end