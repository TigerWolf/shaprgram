require 'rgeo/geo_json'
require 'json'

class ItemsController < ApplicationController

  before_filter :find_project

  def index
    @items = @project.items.includes(:photos)
    respond_to do |format|
      format.html
      format.json { render json: ::ItemsDynatable.new(view_context, @items) }
    end
  end

  def show
    @items = @project.items.page params[:page]
    @item = @project.items.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @item, include: :photos }
      format.geojson do
        payload = RGeo::GeoJSON.encode(@item.point)
        payload[:properties] = @item.import_data
        # Hack - fix this after the weekend
        payload['coordinates'].reverse!
        render json: payload
      end
    end
  end

  def near_me
    if cookies[:lat_lng]
      @lat, @lng = cookies[:lat_lng].split("|")
      @items = @project.items.near(@lng, @lat, 100_000).page params[:page]
    end
  end

  def photo_links
    photos = {}
    @item = @project.items.find(params[:item_id]).photos.each do |photo|
      if photo.is_video?
        photos[photo.id] = link_to 'video', photo.video_url
      else
        photos[photo.id] = photo.image.url(:large)
      end
    end
    render :json => photos
  end

  private

    def find_project
      @project = Project.find(params[:project_id])
    end

end