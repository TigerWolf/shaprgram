class AddAdministrativeBoundryIdToProject < ActiveRecord::Migration
  def change
    add_column :projects, :administrative_boundry_id, :integer
  end
end
