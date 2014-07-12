class AddPhotoVideoField < ActiveRecord::Migration
  def change
    add_column :photos, :video_url, :string
  end
end
