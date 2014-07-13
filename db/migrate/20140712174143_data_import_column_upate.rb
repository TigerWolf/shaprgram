class DataImportColumnUpate < ActiveRecord::Migration
  def change
    add_column :data_imports, :srid, :integer
    add_column :data_imports, :name_field, :string
  end
end
