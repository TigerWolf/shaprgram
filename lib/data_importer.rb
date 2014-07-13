class DataImporter

  def initialize(data_import)
    @data_import = data_import
  end

  def fetch
  end

  # TODO: Sidekiq this!
  def import
    require 'net/http'
    uri = URI(@data_import.data_source_uri)
    response = Net::HTTP.get_response(uri)

    tempfile_name = 'shapefile'
    tempfile_extension = '.shp'
    if response.uri.request_uri =~ /.kmz$/
      tempfile_extension = '.kmz'
    end

    begin
      temp_file = Tempfile.new([tempfile_name, tempfile_extension])
      temp_file.write(response.body)
      temp_file.close
    rescue Encoding::UndefinedConversionError
      temp_file = Tempfile.new([tempfile_name, tempfile_extension], :encoding => 'ascii-8bit')
      temp_file.write(response.body)
      temp_file.close
    end

    case response.uri.request_uri
    when /.km(l|z)$/
      KmlReader.new(Rails.logger).parse(temp_file.path, @data_import)
    when /.csv$/
      CsvReader.new(Rails.logger).parse(temp_file.path, @data_import)
    when /.zip$/
      reader = ShapefileReader.new(Rails.logger)
      path = reader.unzippify!(temp_file.path)
      reader.parse(path, @data_import)
    end
  end
end