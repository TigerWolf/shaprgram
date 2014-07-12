require 'rgeo/shapefile'

class CsvReader

  def initialize(logger)
    @logger = logger
  end

  def logger
    @logger
  end


  def parse(path, project)
    CSV.read(path, headers: true).each do |row|
      next if row[project.metadata["name_column"]].blank?

      item = Item.new({
        name: row[project.metadata["name_column"]], 
        import_data: row.to_json,
        point: row[project.metadata["geom_column"]]
      })

      project.items << item
      logger.info("Imported #{item.name} at #{item.point}")
    end
  end
end