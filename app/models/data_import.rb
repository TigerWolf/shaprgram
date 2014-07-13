class DataImport < ActiveRecord::Base

  belongs_to :project
  has_many :items

  after_create :import_data
  after_update :update_names

  validate :project_id, :data_source_uri, presence: true

  # stop accidental re-importing of multiple datasets
  validates_uniqueness_of :data_source_uri, scope: :project_id

  def status
    'Active'
  end

  DefaultSRIDS = {
    "http://data.sa.gov.au/storage/f/2014-07-08T04%3A56%3A10.225Z/all-sa-hosps.zip" => '3107',
    'http://www.dptiapps.com.au/dataportal/RoadCrashes_shp.zip' => '3107',
    'http://data.gov.au/dataset/13b1196c-7fb7-436a-86bc-ab24c16526de/resource/c28c4bb6-90ef-4a49-bb7e-660fc0942031/download/geelongtrees.zip' => '28355',
    'http://data.gov.au/dataset/cac4aac8-ef3e-4a8d-84ec-63abfc4ff03f/resource/cdb25ba5-21cb-479e-afe1-232a1c507f7e/download/geelongplgrnds.zip' => '28355',
    'http://data.gov.au/dataset/75de1cf0-730d-4133-9955-5d8dfba6c7de/resource/cec7a0b8-6f8c-4a0e-8c82-2dd896f8ac55/download/geelongtoilet.zip' => '28355',
    'http://data.gov.au/dataset/35d45a0f-4fe8-4dc5-8c88-d482f3e519ce/resource/950f6025-3630-447b-903d-006fc36f7d24/download/geelongbbq.zip' => '28355',
    'http://data.gov.au/dataset/7014a203-2e73-46f8-87b6-09e29172bb08/resource/13a9002f-935f-48d2-9ef3-010b0912d936/download/geelongroads.zip' => '28355',
    'http://data.gov.au/dataset/c3449764-6703-4d3a-ad5c-459552c2494b/resource/3bbcb4f7-5126-4904-884c-a1ae291da7eb/download/geelongparking.zip' => '28355',
    'http://data.gov.au/dataset/791ff26e-4cc6-45b3-9db9-0233ca5dc863/resource/359aa508-ef6a-47ff-b3be-c67ed2f21965/download/geelongrdsigns.zip' => '28355'
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
