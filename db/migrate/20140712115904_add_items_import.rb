class AddItemsImport < ActiveRecord::Migration
  def change
    add_column :items, :data_import_id, :integer
    add_column :projects, :boundary, :multi_polygon, srid: 4326
  end
end
