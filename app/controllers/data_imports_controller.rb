class DataImportsController < ApplicationController

  def create
    @data_import = DataImport.new(post_params)

    respond_to do |format|
      if @data_import.save
        format.html { redirect_to :back, notice: 'Data Import was successfully created.' }
        format.json { render :show, status: :created, location: @data_import }
      else
        format.html { redirect_to :back, notice: 'No dice compadrè' }
        format.json { render json: @data_import.errors, status: :unprocessable_entity }
      end
    end

  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:data_import).permit(:project_id, :data_source_uri)
    end
end
