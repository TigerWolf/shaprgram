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

    @factory ||= wgs84_factory = RGeo::Geographic.spherical_factory(srid: 4326)
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
    srs_database = RGeo::CoordSys::SRSDatabase::ActiveRecordTable.new
    factory = RGeo::Geos.factory(srs_database: srs_database, srid: project.srid)
    if srs_database.get(project.srid).proj4.nil?
       raise "It looks like you are affected by https://trello.com/c/h4ZMfLC8/46-bug-todo-convert-between-srids-prior-to-postgis"
    end

    RGeo::Shapefile::Reader.open(path, factory: factory) do |file|
      file.each do |record|
        cartesian_preferred_factory = Project.rgeo_factory_for_column(:point)

        cartesian_cast = RGeo::Feature.cast(record.geometry, cartesian_preferred_factory, :project)

        item =  Item.new({
          name: record.attributes[project.metadata["name_column"]],
          point: cartesian_cast, 
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