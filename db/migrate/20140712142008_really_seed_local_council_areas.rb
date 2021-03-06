class ReallySeedLocalCouncilAreas < ActiveRecord::Migration
  def change
    require 'rgeo/shapefile'

    wgs84_factory = RGeo::Geographic.spherical_factory(srid: 4326)

    f = Rails.root.join('lib', 'data', 'LGA11aAustSimplified.shp')

    areas = []
    RGeo::Shapefile::Reader.open(f.to_path) do |file|
      count = 0
      file.each do |record|
        count += 1
        puts count
        AdministrativeBoundry.create(
          name: "#{record.attributes['LGA_NAME11']}",
          description: "Local Government Area 2011 - #{record.attributes['LGA_NAME11']}",
          area: RGeo::Feature.cast(record.geometry, wgs84_factory, :project)
        )
      end
    end
  end
end
