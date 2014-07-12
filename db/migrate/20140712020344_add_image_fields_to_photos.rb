class AddImageFieldsToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :item_id, :integer
    add_column :photos, :image_file_name, :string
    add_column :photos, :image_content_type, :string
    add_column :photos, :image_file_size, :string
  end
end
