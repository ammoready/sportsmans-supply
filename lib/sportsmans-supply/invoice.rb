module SportsmansSupply
  class Invoice < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    def all
      invoice_filename = connect(@options) { |ftp| ftp.nlst('/invoices/invoices*.csv').last }.split('/').last
      invoice_file = get_file(invoice_filename, 'invoices')

      invoice_data = []

      File.open(invoice_file).each_with_index do |row, i|
        row = row.split(",").map(&:strip)

        if i == 0
          @headers = row.map(&:downcase)
          next
        end

        invoice_data << {
          po_number:      row[@headers.index('order number')],
          invoice_number: row[@headers.index('invoice number')]
        }
      end

      invoice_file.close
      invoice_file.unlink

      invoice_data
    end

  end
end
