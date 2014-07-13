class AddProjectExtras < ActiveRecord::Migration
  def change
    add_column :projects, :srid, :integer
    add_column :projects, :format, :string
    add_column :projects, :metadata, :json
  end
end
