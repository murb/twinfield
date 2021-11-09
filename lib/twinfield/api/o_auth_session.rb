module Twinfield
  module Api
    class OAuthSession
      HEADER_TEMPLATE = {
        "Header" => {},
        attributes!: {
          "Header" => {xmlns: "http://www.twinfield.com/"}
        }
      }

      attr_accessor :cluster, :access_token

      # sets up a new savon client which will be used for current Session
      def initialize
        @cluster = Twinfield.configuration.cluster
        @access_token = Twinfield.configuration.access_token
      end

      # retrieve a session_id and cluster from twinfield
      # relog is by default set to false so when logon is called on your
      # current session, you wont lose your session_id
      def logon(relog = false)
        # no need to logon with OAuth
      end

      # call logon method with relog set to true
      # this wil destroy the current session and cluster
      def relog
        logon(relog = true)
      end

      # after a logon try you can ask the current status
      def status
        if connected?
          return "Ok"
        else
          return "No access token"
        end
      end

      # Returns true or false if current session has a session_id
      # and cluster from twinfield
      def connected?
        !!@access_token && !!@cluster
      end

      def header
        soap_header = HEADER_TEMPLATE

        header_contents = {}
        header_contents["AccessToken"] = access_token if access_token
        header_contents["CompanyCode"] = Twinfield.configuration.company if Twinfield.configuration.company

        soap_header = soap_header.merge({"Header" => header_contents})

        soap_header
      end

    end
  end
end