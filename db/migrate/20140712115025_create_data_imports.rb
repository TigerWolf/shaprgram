class CreateDataImports < ActiveRecord::Migration
  def change
    create_table :data_imports do |t|
      t.integer :project_id
      t.json :field_mappings

      t.timestamps
    end
  end
end
