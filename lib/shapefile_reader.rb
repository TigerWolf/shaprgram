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
    RGeo::Shapefile::Reader.open(path) do |file|
      file.each do |record|
        item =  Item.new({
          name: record.attributes[project.metadata["name_column"]],
          point: record.geometry, 
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