module Twinfield
  class Session
    HEADER_TEMPLATE = {
      "Header" => {},
      attributes!: {
        "Header" => {xmlns: "http://www.twinfield.com/"}
      }
    }

    attr_accessor :session_id, :cluster

    # sets up a new savon client which will be used for current Session
    def initialize
      @client = Savon.client(wsdl: Twinfield::WSDLS[:session],
                             log: !!Twinfield.configuration.log_level,
                             log_level: Twinfield.configuration.log_level || :info)
    end

    # retrieve a session_id and cluster from twinfield
    # relog is by default set to false so when logon is called on your
    # current session, you wont lose your session_id
    def logon(relog = false)
      if connected? && (relog == false)
        "already connected"
      else
        response = @client.call(:logon, message: Twinfield.configuration.to_logon_hash)

        if response.body[:logon_response][:logon_result] == "Ok"
          @session_id = response.header[:header][:session_id]
          @cluster = response.body[:logon_response][:cluster]

          select_company(Twinfield.configuration.company)
        end

        @message = response.body[:logon_response][:logon_result]
      end
    end

    # call logon method with relog set to true
    # this wil destroy the current session and cluster
    def relog
      logon(relog = true)
    end

    # after a logon try you can ask the current status
    def status
      @message
    end

    # Returns true or false if current session has a session_id
    # and cluster from twinfield
    def connected?
      !!@session_id && !!@cluster
    end

    # Abandons the session.
    def abandon
      if session_id
        message = "<Abandon xmlns='http://www.twinfield.com/' />"
        response = @client.call(:Abandon, attributes: { xmlns: "http://www.twinfield.com/" }, soap_header: header, message: message)

        # TODO: Return real status
        # There is no message from twinfield if the action succeeded
        return "Ok"
      else
        "no session found"
      end
    end

    # Keep the session alive, to prevent session time out. A session time out will occur after 20 minutes.
    def keep_alive
      response = @client.request :keep_alive do
        soap.header = header
        soap.body = "<KeepAliveResponse xmlns='http://www.twinfield.com/' />"
      end
      # TODO: Return real status
      # There is no message from twinfield if the action succeeded
      return "Ok"
    end

    def header
      soap_header = HEADER_TEMPLATE
      soap_header = soap_header.merge({"Header"=> {"SessionID"=>session_id}}) if session_id
      soap_header
    end

    # Gets the session's user role.
    def get_role
      # <?xml version="1.0" encoding="utf-8"?>
      # <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      #   <soap:Header>
      #     <Header xmlns="http://www.twinfield.com/">
      #       <SessionID>string</SessionID>
      #     </Header>
      #   </soap:Header>
      #   <soap:Body>
      #     <GetRole xmlns="http://www.twinfield.com/" />
      #   </soap:Body>
      # </soap:Envelope>
      raise NotImplementedError
    end

    # Sends the sms code.
    def sms_send_code
      # <?xml version="1.0" encoding="utf-8"?>
      # <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      #   <soap:Header>
      #     <Header xmlns="http://www.twinfield.com/">
      #       <SessionID>string</SessionID>
      #     </Header>
      #   </soap:Header>
      #   <soap:Body>
      #     <SmsSendCode xmlns="http://www.twinfield.com/" />
      #   </soap:Body>
      # </soap:Envelope>
      raise NotImplementedError
    end

    # Logs on with the sms code.
    def sms_logon
      # <?xml version="1.0" encoding="utf-8"?>
      # <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      #   <soap:Header>
      #     <Header xmlns="http://www.twinfield.com/">
      #       <SessionID>string</SessionID>
      #     </Header>
      #   </soap:Header>
      #   <soap:Body>
      #     <SmsLogon xmlns="http://www.twinfield.com/">
      #       <smsCode>string</smsCode>
      #     </SmsLogon>
      #   </soap:Body>
      # </soap:Envelope>
      raise NotImplementedError
    end

    # Changes the password.
    def change_password
      # <?xml version="1.0" encoding="utf-8"?>
      # <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      #   <soap:Header>
      #     <Header xmlns="http://www.twinfield.com/">
      #       <SessionID>string</SessionID>
      #     </Header>
      #   </soap:Header>
      #   <soap:Body>
      #     <ChangePassword xmlns="http://www.twinfield.com/">
      #       <currentPassword>string</currentPassword>
      #       <newPassword>string</newPassword>
      #     </ChangePassword>
      #   </soap:Body>
      # </soap:Envelope>
      raise NotImplementedError
    end

    # Selects a company.
    def select_company(code)
      message = "<company>#{code}</company>"

      response = Savon.client(wsdl: "#{@cluster}/webservices/session.asmx?wsdl",
                               env_namespace: :soap,
                               encoding: "UTF-8",
                               namespace_identifier: nil).call(:select_company, attributes: { xmlns: "http://www.twinfield.com/" }, soap_header: header, message: message)

      return "Ok"
    end
  end
end
