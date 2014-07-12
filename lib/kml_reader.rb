require 'rgeo/shapefile'
require 'geo_ruby/kml'  

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

  def parse(path, project)

    if path =~ /.kmz\z/
      path = unzippify!(path)
    end


    factory = GeoRuby::SimpleFeatures::GeometryFactory.new
    parser = GeoRuby::KmlParser.new(factory)
    
    parser.parse(File.read(path)).each do |row|
      require 'pry'
      binding.pry
      raise 'yo'
    end


    # CSV.read(path, headers: true).each do |row|
    #   next if row[project.metadata["name_column"]].blank?

    #   # f = RGeo::Geographic.projected_factory(:projection_proj4 => proj4, :projection_srid => srid)
    #   # f = wgs84_factory.parse_wkt(row[project.metadata["geom_column"]])
    #   # cartesian_cast = RGeo::Feature.cast(f, wgs84_factory, :project)

    #   item = Item.new({
    #     name: row[project.metadata["name_column"]], 
    #     import_data: row.to_json,
    #     point: wgs84_factory.parse_wkt(row[project.metadata["geom_column"]])
    #   })

    #   project.items << item
    #   logger.info("Imported #{item.name} at #{item.point}")
    # end
  end
end