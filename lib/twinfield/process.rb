module Twinfield
  module Process
    extend self

    def session
      @session ||= Twinfield.configuration.session_class.new
      @session.logon
      return @session
    end

    def session= session
      @session = session
    end

    def client
      @client ||= Savon.client(wsdl: "#{session.cluster}#{Twinfield::WSDLS[:process]}",
                               env_namespace: :soap,
                               encoding: "UTF-8",
                               namespace_identifier: nil)
    end

    def actions
      @actions ||= client.operations
    end

    def request(action=:process_xml_string, options={}, &block)

      if actions.include?(action)
        message = "<xmlRequest><![CDATA[#{block.call}]]></xmlRequest>"

        client.call(action, attributes: { xmlns: "http://www.twinfield.com/" }, soap_header: session.header, message: message)
      else
        "action not found"
      end
    end

    def options_to_xml(options)
      options.map {|k,v| "<#{k}>#{v}</#{k}>" }.join("\n")
    end
  end
end
