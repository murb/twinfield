module FinderStubs
  def stub_finder type, oauth: false
    stub_request(:post, "https://accounting.twinfield.com/webservices/finder.asmx")
      .with(
        body: /<Search xmlns="http:\/\/www.twinfield.com\/"><type>#{type}<\/type><pattern>\*<\/pattern><field>0<\/field><firstRow>1<\/firstRow><maxRows>100<\/maxRows><options><\/options><\/Search>/,
        headers: {
          "Soapaction" => '"http://www.twinfield.com/Search"'
        }
      )
      .to_return(status: 200, body: File.read(File.expand_path("../../fixtures/cluster/finder/#{type.downcase}.xml", __FILE__)), headers: {})
  end

  private

  def twinfield_header(oauth, company = nil)
    company_fragment = company ? "<CompanyCode>#{company}</CompanyCode>" : ""
    oauth ? "<Header xmlns=\"http://www.twinfield.com/\"><AccessToken>2b128baa05dd3cabc61e534435884961</AccessToken>#{company_fragment}</Header>" : "<Header xmlns=\"http://www.twinfield.com/\"><SessionID>session_id</SessionID></Header>"
  end
end
