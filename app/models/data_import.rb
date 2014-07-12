class DataImport < ActiveRecord::Base

  belongs_to :project
  has_many :items

  after_create :import_data
  before_update :update_names

  validate :project_id, :data_source_uri, presence: true

  # stop accidental re-importing of multiple datasets
  validates_uniqueness_of :data_source_uri, scope: :project_id

  def status
    'Active'
  end

  DefaultSRIDS = {
    "http://data.sa.gov.au/storage/f/2014-07-08T04%3A56%3A10.225Z/all-sa-hosps.zip" => '3107'
  }

  def srid
    self.read_attribute(:srid) || pick_default_srid
  end

  def pick_default_srid
    DefaultSRIDS[data_source_uri] || 4326
  end

  def item_attributes
    items.first.import_data.keys unless items.blank?
  end

  def update_names
    items.each { |i| i.update_attribute(:name, i.import_data[name_field]) }
  end

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
      KmlReader.new(Rails.logger).parse(temp_file.path, self)
    when /.csv$/
      CsvReader.new(Rails.logger).parse(temp_file.path, self)
    when /.zip$/
      reader = ShapefileReader.new(Rails.logger)
      path = reader.unzippify!(temp_file.path)
      reader.parse(path, self)
    end
  end

end
