namespace :fake do
  require 'csv'
  require 'faker'
  require 'logger'
  require 'rgeo'

  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO


  desc "Import a faux shapefile project for testing"
  task shapefile_project: :environment do
    p = Project.new(name: Faker::Lorem.sentence)
    p.url = 'http://opendata.adelaidecitycouncil.com/seats/seats.csv'
    p.format = "shp"
    p.save
  end

  desc "Import a faux csv project for testing"
  task csv_project: :environment do
    path = File.join(File.dirname(__FILE__), "data", "seats.csv") 
    

    p = Project.new(name: Faker::Lorem.sentence)
    p.format = "csv"
    p.srid = 4326
    p.metadata = {
      geom_column: "Geometry",
      name_column: "Asset ID (Identifier)"
    }

    CSV.read(path, headers: true).each do |row|
      next if row[p.metadata["name_column"]].blank?

      item = Item.new({
        name: row[p.metadata["name_column"]], 
        import_data: row,
        point: row[p.metadata["geom_column"]]
      })

      p.items << item
      logger.info("Imported #{item.name} at #{item.point}")
    end

    p.save
  end
end