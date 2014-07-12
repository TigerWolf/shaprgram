require 'rgeo/shapefile'
require 'geo_ruby/kml'  
require 'zip'

class KmlReader

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

    Dir["#{temp_path}/*.kml"].first
  end

  def parse(path, data_import)

    if path =~ /.kmz\z/
      path = unzippify!(path)
    end

    # establish whether any srid casting needs to be done.

    factory = GeoRuby::SimpleFeatures::GeometryFactory.new
    parser = GeoRuby::KmlParser.new(factory)
    rgeo_factory = RGeo::Cartesian.factory

    parser.parse(File.read(path)).each do |row|

      if data_import.project.administrative_boundry
        next unless data_import.project.administrative_boundry.area.contains? rgeo_factory.parse_wkt(row.as_wkt)
      end

      item = Item.new({
        name:        'Temp KML', 
        import_data: row.to_json,
        point:       row.as_wkt,
        data_import: data_import,
        project_id:  data_import.project.id
      })

      item.save

      logger.info("Imported #{item.name} at #{item.point}")
    end

  end
end