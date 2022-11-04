require 'base64'
require 'json'

module Twinfield

  # Used for configuration of the Twinfield gem.

  class Configuration
    class Error < StandardError

    end
    attr_accessor :session_type # Twinfield::Api::OAuthSession or Twinfield::Api::Session

    # in case Twinfield::Api::Session is used
    attr_accessor :username
    attr_accessor :password
    attr_accessor :organisation
    attr_accessor :company

    # in case Twinfield::Api::OAuthSession is used
    attr_accessor :cluster
    attr_accessor :access_token

    # Log level, e.g. :info, :debug; currently only forwarded to Savon
    attr_accessor :log_level
    attr_accessor :logger


    def to_logon_hash
      {
        "user" => @username,
        "password" => @password,
        "organisation" => @organisation
      }
    end

    def access_token_expired?
      Time.at(JSON.parse(Base64.decode64 access_token.split(".")[1])["exp"]) < Time.now
    rescue StandardError => e
      raise Twinfield::Configuration::Error, "No valid access token provided (#{e.message})"
    end

    def session_class
      case session_type
      when "Twinfield::Api::OAuthSession"
        return Twinfield::Api::OAuthSession
      else
        return Twinfield::Api::Session
      end
    end
  end
end
