require 'csv'
require 'faker'

namespace :fake do

  def build_project
    Project.new(name: Faker::Lorem.sentence)
  end
  
  desc "Import a faux shapefile project for testing"
  task :shapefile_project do
    p = build_project
    p.url = 'http://opendata.adelaidecitycouncil.com/seats/seats.csv'
    p.format = "shp"
    p.save
  end

  desc "Import a faux csv project for testing"
  task :csv_project do
    path = File.join(File.dirname(__FILE__), "data", "seats.csv") 
    

    p = build_project
    p.format = "csv"
    p.metadata = {
      geom_column: "Geometry",
      name_column: "Asset ID (Identifier)"
    }

    CSV.table(path).each do |row|
      item = Item.new({
        name: row[p.metadata[:name_column]], 
        geom: row[p.metadata[:geom_column]] # TODO ST_FromText? rgeo equiv?
      })
      p.items << item
    end

    p.save
  end
end