class PhotosController < ApplicationController

    # POST /posts
  # POST /posts.json
  def create
    @photo = Photo.new(post_params)

    respond_to do |format|
      if @photo.save
        format.html { redirect_to :back, notice: 'Photo was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { redirect_to :back, notice: 'No dice compadrè' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:photo).permit(:image, :item_id)
    end

end