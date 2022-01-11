require 'sportsmans-supply/version'

require 'csv'
require 'net/ftp'
require 'tempfile'

require 'sportsmans-supply/base'
require 'sportsmans-supply/catalog'
require 'sportsmans-supply/inventory'
require 'sportsmans-supply/order'
require 'sportsmans-supply/user'

module SportsmansSupply
  class InvalidOrder < StandardError; end
  class NotAuthenticated < StandardError; end
  class FileOrDirectoryNotFound < StandardError; end

  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield(config)
  end

  class Configuration
    attr_accessor :ftp_host
    attr_accessor :catalog_filename
    attr_accessor :inventory_filename

    def initialize
      @ftp_host ||= 'www.rapidretail.net'
      @catalog_filename ||= 'rr_products.csv'
      @inventory_filename ||= 'rr_pricing_availability.csv'
    end
  end
end
