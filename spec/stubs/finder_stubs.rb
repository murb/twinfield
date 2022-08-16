module FinderStubs
  def stub_finder type, oauth: false
    stub_request(:post, "https://accounting.twinfield.com/webservices/finder.asmx").
      with(
        body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><soap:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.twinfield.com/\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><Header xmlns=\"http://www.twinfield.com/\"><SessionID>session_id</SessionID></Header></soap:Header><soap:Body><Search xmlns=\"http://www.twinfield.com/\"><type>IVT</type><pattern>*</pattern><field>0</field><firstRow>1</firstRow><maxRows>100</maxRows><options></options></Search></soap:Body></soap:Envelope>",
        headers: {
    	  'Soapaction'=>'"http://www.twinfield.com/Search"'
        }).
        to_return(status: 200, body: File.read(File.expand_path("../../fixtures/cluster/finder/#{type.downcase}.xml", __FILE__)), headers: {})
  end

  private

  def twinfield_header(oauth, company=nil)
    company_fragment = company ? "<CompanyCode>#{company}</CompanyCode>" : ""
    oauth ? "<Header xmlns=\"http://www.twinfield.com/\"><AccessToken>2b128baa05dd3cabc61e534435884961</AccessToken>#{company_fragment}</Header>" : "<Header xmlns=\"http://www.twinfield.com/\"><SessionID>session_id</SessionID></Header>"
  end

end
