require 'rgeo/shapefile'

class CsvReader

  def initialize(logger)
    @logger = logger
  end

  def logger
    @logger
  end

  def parse(path, data_import)

    CSV.read(path, headers: true).each do |row|
      # next if row[project.metadata["name_column"]].blank?

      # TODO: apply SRID casting here if required?
      # TODO: establish geom_column here?

      item = Item.new({
        name:           'Temp CSV', 
        # point:          row[project.metadata["geom_column"]],
        import_data:    row.to_json,
        data_import_id: data_import.id,
        project_id:     data_import.project.id
      })

      item.save

      logger.info("Imported #{item.name} at #{item.point}")
    end
  end
end