namespace :fake do
  require 'csv'
  require 'faker'
  require 'logger'
  require 'rgeo'
  require 'zip'

  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO


  desc "Import a faux shapefile project for testing"
  task shapefile_project: :environment do
    project = Project.create(name: Faker::Lorem.sentence)
    data_import = DataImport.new(data_source_uri: nil, srid: 28356, project_id: project.id)

    reader = ShapefileReader.new(logger)

    # p.url = 'http://data.gov.au/storage/f/2013-09-09T03%3A26%3A41.342Z/bbq.zip'
    # data_import.srid = 28356 # GDA94, not WSG_84
    # project.format = "shp"
    # project.metadata = {
    #   name_column: "ASSET_NUMB"
    # }


    shp_path = reader.unzippify!("lib/tasks/data/bbq.zip")
    raise "Invalid file" unless shp_path

    reader.parse(shp_path, data_import)

    data_import.save!
  end

  desc "Import a faux csv project for testing"
  task csv_project: :environment do
    path = File.join(File.dirname(__FILE__), "data", "seats.csv") 
    

    project = Project.create(name: Faker::Lorem.sentence)
    project.format = "csv"
    project.srid = 4326
    project.metadata = {
      geom_column: "Geometry",
      name_column: "Asset ID (Identifier)"
    }

    reader = CsvReader.new(logger)
    reader.parse(path, project)

    project.save!
  end

  desc "Import a faux kml/kmz project for testing"
  task kml_project: :environment do
    path = File.join(File.dirname(__FILE__), "data", "seats.kmz") 

    project = Project.create(name: Faker::Lorem.sentence)
    project.format = "kml"
    project.srid = 4326
    project.metadata = {
      geom_column: "Geometry",
      name_column: "Asset ID (Identifier)"
    }

    reader = KmlReader.new(logger)
    reader.parse(path, project)

    project.save!
  end
end