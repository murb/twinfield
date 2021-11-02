module ProcessxmlStubs
  def stub_processxml_wsdl
    stub_request(:get, "https://accounting.twinfield.com/webservices/processxml.asmx?wsdl").
    to_return(status: 200, body: File.read(File.expand_path('../../fixtures/cluster/processxml/wsdl.xml', __FILE__)) )
  end

  def stub_processxml_list_dimensions dimension_type: 'DEB', company: 'company'
    stub_request(:post, "https://accounting.twinfield.com/webservices/processxml.asmx").
      with(
        body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><soap:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.twinfield.com/\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><Header xmlns=\"http://www.twinfield.com/\"><SessionID>session_id</SessionID></Header></soap:Header><soap:Body><ProcessXmlString xmlns=\"http://www.twinfield.com/\"><xmlRequest><![CDATA[\n            <list>\n              <type>dimensions</type>\n              <dimtype>#{dimension_type}</dimtype>\n<office>#{company}</office>\n            </list>\n          ]]></xmlRequest></ProcessXmlString></soap:Body></soap:Envelope>",
        headers: {
    	  'Soapaction'=>'"http://www.twinfield.com/ProcessXmlString"',
        }).
      to_return(status: 200, body: File.read(File.expand_path('../../fixtures/cluster/processxml/response.xml', __FILE__)), headers: {})
  end
end