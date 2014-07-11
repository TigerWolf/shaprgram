class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :description
      t.string :data_source_uri
      t.string :status
      t.integer :user_id

      t.timestamps
    end
  end
end
