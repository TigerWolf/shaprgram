class DataImport < ActiveRecord::Base

  belongs_to :project
  has_many :items

  before_save :import_data

  validate :project_id, :data_source_uri, presence: true

  # stop accidental re-importing of multiple datasets
  validates_uniqueness_of :data_source_uri, scope: :project_id

  # TODO: Sidekiq this!
  def import_data
    require 'net/http'
    uri = URI(data_source_uri)
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
      KmlReader.new(Rails.logger).parse(temp_file.path, project)
    when /.csv$/
      CsvReader.new(Rails.logger).parse(temp_file.path, project)
    when /.zip$/
      reader = ShapefileReader.new(Rails.logger)
      path = reader.unzippify!(temp_file.path)
      reader.parse(path, project)
    end
  end

end
