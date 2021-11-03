module Twinfield

  # Used for configuration of the Twinfield gem.

  class Configuration
    attr_accessor :session_type # Twinfield::OAuthSession or Twinfield::Session

    # in case Twinfield::Session is used
    attr_accessor :username
    attr_accessor :password
    attr_accessor :organisation
    attr_accessor :company

    # in case Twinfield::OAuthSession is used
    attr_accessor :cluster
    attr_accessor :access_token


    def to_logon_hash
      {
        "user" => @username,
        "password" => @password,
        "organisation" => @organisation
      }
    end

    def session_class
      case session_type
      when "Twinfield::OAuthSession"
        return Twinfield::OAuthSession
      else
        return Twinfield::Session
      end
    end
  end
end
