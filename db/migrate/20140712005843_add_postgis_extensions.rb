class AddPostgisExtensions < ActiveRecord::Migration
  def change
    enable_extension "postgis"
    enable_extension "postgis_topology"
    enable_extension "fuzzystrmatch"
    enable_extension "postgis_tiger_geocoder"
  end
end
