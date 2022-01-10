module SportsmansSupply
  class Order < Base

    HEADERS = [
      'cust #', 'order id', 'status', 'order received date', 'ship method code', 'ship to name', 'ship to line 1',
      'ship to line 2', 'ship to city', 'ship to state', 'ship to zip', 'ship to country', 'ship to phone', 'cost',
      'sku/upc', 'quantity ordered'
    ]

    def initialize(options = {})
      requires!(options, :username, :password)

      @options = options
      @items = []
    end

    def add_item(item = {})
      requires!(item, :item_number, :quantity)

      @items << item
    end

    def submit(options = {})
      raise SportsmansSupply::InvalidOrder.new("Must add items with #add_item before submitting") if @items.empty?

      requires!(options, :customer_number, :po_number, :shipping)
      requires!(options[:shipping], :name, :address_1, :city, :state, :zip)

      filename = [options[:customer_number], Time.now.strftime("%m%d%y%H%M%S"), options[:po_number]].join('_') + '.csv'
      order_file = Tempfile.new(filename)

      CSV.open(order_file.path, 'w+', col_sep: ",") do |csv|
        csv << HEADERS

        @items.each do |item|
          item_data = [
            options[:customer_number],
            options[:po_number],
            'NEW',
            Time.now.strftime("%-m/%d/%Y"),
            options[:shipping][:method_code] || 'Best Way',
            options[:shipping][:name],
            options[:shipping][:address_1],
            options[:shipping][:address_2],
            options[:shipping][:city],
            options[:shipping][:state],
            options[:shipping][:zip],
            options[:shipping][:country] || 'USA',
            options[:shipping][:phone],
            '',
            item[:item_number],
            item[:quantity]
          ]

          csv << item_data
        end
      end

      connect(@options) do |ftp|
        ftp.chdir('orders')
        ftp.puttextfile(order_file.path, filename)
      end

      order_file.close
      order_file.unlink
    end

  end
end
