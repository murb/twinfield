module Twinfield
  module Process
    extend self

    def session
      @session ||= Twinfield::Session.new
      @session.logon
       return @session
    end

    def client
      @client ||= Savon.client(wsdl: "#{session.cluster}#{Twinfield::WSDLS[:process]}",
                               env_namespace: :soap,
                               encoding: "UTF-8",
                               namespace_identifier: nil)
    end

    def list(element, options = {})
      Twinfield::Process.request(:process_xml_string) do
        %Q(
          <list>
            <type>#{element.to_s}</type>
            #{"<dimtype>#{options[:dimtype]}</dimtype>" if options[:dimtype]}
          </list>
        )
      end
    end

    def read(element, options = {})
      Twinfield::Process.request(:process_xml_string) do
        %Q(
          <read>
            <type>#{element.to_s}</type>
            #{"<code>#{options[:code]}</code>" if options[:code]}
          </read>
        )
      end
    end

    def actions
      @actions ||= client.operations
    end

    def request(action, &block)
      if actions.include?(action)
        header = { "Header" => { "SessionID" => session.session_id }, attributes!: { "Header" => { "xmlns" => "http://www.twinfield.com/"} } }
        message = "<xmlRequest><![CDATA[#{block.try(:call)}]]></xmlRequest>"
        response = client.call(action, attributes: { xmlns: "http://www.twinfield.com/" }, soap_header: header, message: message)
      else
        "action not found"
      end
    end
  end
end