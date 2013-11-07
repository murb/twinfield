module Twinfield
  module Process
    extend self

    def session
      @session = Twinfield::Session.new
      @session.logon
       return @session
    end

    def client
      @client ||= Savon.client(wsdl: "#{session.cluster}#{Twinfield::WSDLS[:process]}",
                               env_namespace: :soap,
                               encoding: "UTF-8",
                               namespace_identifier: nil)
    end

    def request(action, &block)
      if actions.include?(action)
        header = { "Header" => { "SessionID" => session.session_id }, attributes!: { "Header" => { "xmlns" => "http://www.twinfield.com/"} } }
        message = "<xmlRequest><![CDATA[#{block.try(:call)}]]></xmlRequest>"
        client.call(action, attributes: { xmlns: "http://www.twinfield.com/" }, soap_header: header, message: message)
      else
        "action not found"
      end
    end

    def self.actions
      @actions ||= client.operations
    end
  end
end