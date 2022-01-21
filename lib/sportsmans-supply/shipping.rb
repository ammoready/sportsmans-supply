module SportsmansSupply
  class Shipping < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    def all
      tracking_filename = connect(@options) { |ftp| ftp.nlst('/shipping/tracking*.csv').last }&.split('/')&.last

      return [] if tracking_filename.nil?

      tracking_file = get_file(tracking_filename, 'shipping')
      tracking_data = []

      File.open(tracking_file).each_with_index do |row, i|
        row = row.split(",").map(&:strip)

        if i == 0
          @headers = row.map(&:downcase)
          next
        end

        tracking_data << {
          po_number:       row[@headers.index('customer po#')],
          tracking_number: row[@headers.index('tracking numbers')],
          carrier:         row[@headers.index('actual shipping carrier')]
        }
      end

      tracking_file.close
      tracking_file.unlink

      tracking_data
    end

  end
end
