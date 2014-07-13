class SeedLocalCouncilAreas < ActiveRecord::Migration
  def change

    create_table :administrative_boundries do |t|
      t.string :name
      t.text   :description
      t.multi_polygon :area, srid: 4326
      t.timestamps
    end

  end
end
