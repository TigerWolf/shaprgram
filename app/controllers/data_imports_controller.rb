class DataImportsController < ApplicationController

  def create
    @data_import = DataImport.new(post_params)

    respond_to do |format|
      if @data_import.save
        format.html { redirect_to edit_data_import_path(@data_import), notice: 'Data Import was successfully created.' }
        format.json { render :show, status: :created, location: @data_import }
      else
        format.html { redirect_to :back, notice: "Unable to Import data. Please make sure you haven't already imported this dataset." }
        format.json { render json: @data_import.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @data_import = DataImport.find(params[:id])
  end

  def update
    @data_import = DataImport.find(params[:id])

    respond_to do |format|
      if @data_import.update_attributes(post_params)
        format.html { redirect_to edit_data_import_path(@data_import), notice: 'Data Import was successfully created.' }
        format.json { render :show, status: :created, location: @data_import }
      else
        format.html { redirect_to :back, notice: "Unable to Import data. Please make sure you haven't already imported this dataset." }
        format.json { render json: @data_import.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:data_import).permit(:project_id, :data_source_uri, :srid, :name_field)
    end

end
