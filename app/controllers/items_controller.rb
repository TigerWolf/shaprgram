require 'rgeo/geo_json'
require 'json'

class ItemsController < ApplicationController
  
  before_filter :find_project

  def index
    @items = @project.items.page params[:page]
  end

  def show
    @items = @project.items.page params[:page]
    @item = @project.items.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @item }
      format.geojson do
        payload = RGeo::GeoJSON.encode(@item.point)
        payload[:properties] = @item.import_data
      
        render json: payload
      end
    end
  end

  private

    def find_project
      @project = Project.find(params[:project_id])
    end

end