module SportsmansSupply
  class User < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.authenticated?(options = {})
      requires!(options, :username, :password)
      new(options).authenticated?
    end

    def authenticated?
      connect(@options) { |ftp| ftp.pwd }
      true
    rescue SportsmansSupply::NotAuthenticated, Net::FTPPermError
      false
    end

  end
end
