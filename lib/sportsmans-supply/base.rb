module SportsmansSupply
  class Base

    def self.connect(options = {})
      requires!(options, :username, :password)

      Net::FTP.open(SportsmansSupply.config.ftp_host, options[:username], options[:password]) do |ftp|
        yield(ftp)
      end
    end

    protected

    def requires!(*args)
      self.class.requires!(*args)
    end

    def self.requires!(hash, *params)
      params.each do |param|
        if param.is_a?(Array)
          raise ArgumentError.new("Missing required parameter: #{param.first}") unless hash.has_key?(param.first)

          valid_options = param[1..-1]
          raise ArgumentError.new("Parameter: #{param.first} must be one of: #{valid_options.join(', ')}") unless valid_options.include?(hash[param.first])
        else
          raise ArgumentError.new("Missing required parameter: #{param}") unless hash.has_key?(param)
        end
      end
    end

    def connect(options)
      self.class.connect(options) do |ftp|
        begin
          yield(ftp)
        end
      end
    end

    def get_file(filename, file_directory = nil)
      connect(@options) do |ftp|
        tempfile = Tempfile.new
        ftp.getbinaryfile(File.join(file_directory, filename), tempfile.path)
        tempfile
      end
    end

  end
end
