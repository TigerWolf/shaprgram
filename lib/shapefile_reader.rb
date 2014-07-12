require 'rgeo/shapefile'
require 'fileutils'
class ShapefileReader

  def initialize(logger)
    @logger = logger
  end

  def logger
    @logger
  end

  def temp_path
    @target ||= Dir.mktmpdir
  end

  def wgs84_factory
wgs84_proj4 = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'
wgs84_wkt = <<WKT
  GEOGCS["WGS 84",
    DATUM["WGS_1984",
      SPHEROID["WGS 84",6378137,298.257223563,
        AUTHORITY["EPSG","7030"]],
      AUTHORITY["EPSG","6326"]],
    PRIMEM["Greenwich",0,
      AUTHORITY["EPSG","8901"]],
    UNIT["degree",0.01745329251994328,
      AUTHORITY["EPSG","9122"]],
    AUTHORITY["EPSG","4326"]]
WKT

    @factory ||= wgs84_factory = RGeo::Geographic.spherical_factory(srid: 4326, proj4:wgs84_proj4, coord_sys: wgs84_wkt)
  end

  def unzippify!(path)

    Zip::File.open(path) do |zip_file|
      zip_file.each do |entry|
        # Extract to file/directory/symlink
        logger.info("Extracting #{entry.name} to #{temp_path}/#{entry.name}")
        entry.extract("#{temp_path}/#{entry.name}")
      end
    end

    Dir["#{temp_path}/*.shp"].first
  end

  def parse(path, project)
    factory = RGeo::Geographic.spherical_factory(srid: project.srid)
    RGeo::Shapefile::Reader.open(path, factory: factory) do |file|
      file.each do |record|
        item =  Item.new({
          name: record.attributes[project.metadata["name_column"]],
          point: RGeo::Feature.cast(record.geometry, factory: wgs84_factory, project: true), 
          import_data: record.attributes
        })
        project.items << item

        logger.info("Imported #{item.name} at #{item.point}")
      end
    end

    # Success - we can ditch the working data
    FileUtils.rm_rf(temp_path)
  end
end