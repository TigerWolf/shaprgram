class DataImporter

  def initialize(data_import)
    @data_import = data_import
    @uri = URI(@data_import.data_source_uri)
  end

  #
  # Based on the data_import configuration, fetch
  # the raw content via http and dump it into a Tempfile.
  #
  # TODO Multiple protocols
  #
  def fetch
    require 'net/http'
    
    response = Net::HTTP.get_response(@uri)

    tempfile_name = 'spatialimport'
    tempfile_extension = File.extname(response.uri.to_s)

    begin
      temp_file = Tempfile.new([tempfile_name, tempfile_extension])
      temp_file.write(response.body)
      temp_file.close
    rescue Encoding::UndefinedConversionError
      temp_file = Tempfile.new([tempfile_name, tempfile_extension], :encoding => 'ascii-8bit')
      temp_file.write(response.body)
      temp_file.close
    end

    temp_file
  end

  #
  # Choose an appropriate strategy to import a file with, and 
  # to populate the metadata.
  #
  # TODO: Sidekiq this!
  # TODO: Automatic shapefile SRID guessing.
  #
  def import(path)
    case @uri.request_uri
    when /.csv$/
      CsvReader.new(Rails.logger).parse(path, @data_import)
    else
      new_path = ShapeConverter.convert_to_4326(path)
      reader = ShapeConverter.new(Rails.logger)
      reader.parse(new_path, @data_import)
    end
  end

end