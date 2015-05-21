module Twinfield

  # Used for configuration of the Twinfield gem.

  class Configuration

    attr_accessor :username
    attr_accessor :password
    attr_accessor :organisation
    attr_accessor :company

    def to_logon_hash
      {
        "user" => @username,
        "password" => @password,
        "organisation" => @organisation
      }
    end
  end
end
