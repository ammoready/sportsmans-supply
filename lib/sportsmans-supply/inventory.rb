module SportsmansSupply
  class Inventory < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end
    class << self; alias_method :quantity, :all; end

    def all
      inventory_file = get_file(SportsmansSupply.config.inventory_filename, 'pricing-availability')
      inventory_data = []

      File.open(inventory_file).each_with_index do |row, i|
        row = row.split(",").map(&:strip)

        if i == 0
          @headers = row.map(&:downcase)
          next
        end

        inventory_data << {
          item_identifier: row[@headers.index('sku')],
          quantity:        row[@headers.index('qty')].to_i,
          price:           row[@headers.index('rapid retail price')].strip,
        }
      end

      inventory_file.close
      inventory_file.unlink

      inventory_data
    end

  end
end
