class AddItems < ActiveRecord::Migration
  
  unless Item.table_exists?
    def change
      create_table :items do |t|
        t.integer :project_id
        t.string :name
        t.point :point, srid: 4326
        t.json :import_data

        t.timestamps
      end
    end
  end
end
