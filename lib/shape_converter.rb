require 'rgeo/shapefile'
require 'fileutils'
require 'zip'

class ShapeConverter

  def initialize(logger)
    @logger = logger
  end

  def logger
    @logger
  end

  def temp_path
    @target ||= Dir.mktmpdir
  end

  def parse(path, data_import)
    factory = RGeo::Geographic.spherical_factory(srid: 4326)

    boundary = data_import.project.administrative_boundry

    RGeo::Shapefile::Reader.open(path, factory: factory) do |file|
      items = []

      file.each do |record|

        if boundary
          next unless boundary.area.contains? record.geometry
        end

        item = Item.new({
          name:        'Temp SHP', #record.attributes[project.metadata["name_column"]],
          point:       record.geometry,
          import_data: record.attributes,
          project_id:  data_import.project.id,
          data_import: data_import
        })
        items << item
        logger.info("Imported #{item.name} at #{item.point}")
      end

      Item.import items
    end

    rescue ArgumentError
    ensure
    # Success - we can ditch the working data
    FileUtils.rm_rf(temp_path)
  end

  def self.convert_to_4326(path)
    Dir['/tmp/new_shapefile.*'].each do |file|
      File.delete(file)
    end
    new_path = '/tmp/new_shapefile.shp'

    raise 'Import Failed' unless `4326_converter #{path.path} #{new_path}`
    new_path
  end
end