require 'rgeo/shapefile'

class ShapefileReader

  def initialize(logger)
    @logger = logger
  end

  def logger
    @logger
  end

  def unzippify!()
    Rails.logger.warn("Some pretty hard coded junk here! MUST refactor to a .zip library and identify the right .shp")
    
    path = "bbq.zip" 
    %x{cd lib/tasks/data/ && unzip -o #{path}}

    shp_path = File.join(File.dirname(__FILE__), "tasks", "data", "Barbeque.shp") 
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
  end
end