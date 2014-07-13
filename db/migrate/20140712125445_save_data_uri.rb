class SaveDataUri < ActiveRecord::Migration
  def change
    add_column :data_imports, :data_source_uri, :string
  end
end
