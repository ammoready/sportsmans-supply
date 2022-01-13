module SportsmansSupply
  class Catalog < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    def all
      catalog_file = get_file(SportsmansSupply.config.catalog_filename, 'products')
      inventory_file = get_file(SportsmansSupply.config.inventory_filename, 'pricing-availability')

      inventory_data = {}
      catalog_data = []

      File.open(inventory_file).each_with_index do |row, i|
        row = row.split(",").map(&:strip)

        if i == 0
          @headers = row.map(&:downcase)
          next
        end

        inventory_data[row[@headers.index('sku')]] = {
          price: row[@headers.index('rapid retail price')].to_f,
          quantity: row[@headers.index('qty')].to_i
        }
      end

      File.open(catalog_file).each_with_index do |row, i|
        row = row.split("|").map(&:strip)

        if i == 0
          @headers = row.map(&:downcase)
          next
        end

        description = row[@headers.index('description')]
        sku = row[@headers.index('sku')]
        inventory_datum = inventory_data[sku]

        next if inventory_datum.nil?

        catalog_data << {
          mfg_number:        row[@headers.index('mpn')],
          upc:               row[@headers.index('upc code')],
          name:              description,
          quantity:          inventory_datum[:quantity],
          price:             inventory_datum[:price],
          map_price:         row[@headers.index('map')].to_f,
          msrp:              row[@headers.index('msrp')].to_f,
          brand:             row[@headers.index('manufacturer')],
          item_identifier:   sku,
          category:          row[@headers.index('category')],
          subcategory:       row[@headers.index('subcategory')],
          short_description: description,
          long_description:  row[@headers.index('detailed description')],
          weight:            [row[@headers.index('weight')], row[@headers.index('weight units')]].join,
          features:          {
            dimension_length: row[@headers.index('dimensionl')],
            dimension_width:  row[@headers.index('dimensionw')],
            dimension_height: row[@headers.index('dimensionh')],
            shipping_length:  row[@headers.index('shipping length')],
            shipping_width:   row[@headers.index('shipping width')],
            shipping_height:  row[@headers.index('shipping height')],
            image_name:       row[@headers.index('image url')],
          }
        }
      end

      [catalog_file, inventory_file].each { |f| f.close; f.unlink }

      catalog_data
    end

  end
end
