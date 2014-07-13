require 'rgeo/shapefile'
require 'fileutils'
require 'zip'

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
# wgs84_proj4 = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs'
# wgs84_wkt = <<WKT
#   GEOGCS["WGS 84",
#     DATUM["WGS_1984",
#       SPHEROID["WGS 84",6378137,298.257223563,
#         AUTHORITY["EPSG","7030"]],
#       AUTHORITY["EPSG","6326"]],
#     PRIMEM["Greenwich",0,
#       AUTHORITY["EPSG","8901"]],
#     UNIT["degree",0.01745329251994328,
#       AUTHORITY["EPSG","9122"]],
#     AUTHORITY["EPSG","4326"]]
# WKT

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


  # How to handle SRID??

  def parse(path, data_import)

    srs_database = RGeo::CoordSys::SRSDatabase::ActiveRecordTable.new
    factory = RGeo::Geos.factory(srs_database: srs_database, srid: data_import.srid)


    # lat, lng = -73.700666, 45.528719

    # srid = new_crs_srid = 32188
    # proj4 = new_crs_proj4 = "+proj=tmerc +lat_0=0 +lon_0=-73.5 +k=0.9999 +x_0=304800 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs " ##obtained from spatialreference.org
    # f = new_crs_factory = RGeo::Geographic.projected_factory(:projection_proj4 => proj4, :projection_srid => srid)
    # geom_shape_32188 = f.parse_wkt("POINT (#{lng} #{lat})").projection

    # require 'pry'
    # binding.pry

    # if srs_database.get(data_import.srid).proj4.nil?
    #   raise "It looks like you are affected by https://trello.com/c/h4ZMfLC8/46-bug-todo-convert-between-srids-prior-to-postgis"
    # end

    RGeo::Shapefile::Reader.open(path, factory: factory) do |file|

      items = []
      file.each do |record|

        cartesian_cast = RGeo::Feature.cast(record.geometry, wgs84_factory, :project)
        cartesian_cast = cartesian_cast.factory.point(cartesian_cast.lon - 0.001357816, cartesian_cast.lat  - 0.1796842886)

        if data_import.project.administrative_boundry
          next unless data_import.project.administrative_boundry.area.contains?(cartesian_cast)
        end

        item = Item.new({
          name:        'Temp SHP', #record.attributes[project.metadata["name_column"]],
          point:       cartesian_cast,
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
end