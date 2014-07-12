class ItemsController < ApplicationController
  
  before_filter :find_project

  def index
    @items = @project.items.page params[:page]
  end

  def show
    @items = @project.items.page params[:page]
    @item = @project.items.find(params[:id])
  end

  private

    def find_project
      @project = Project.find(params[:project_id])
    end

end