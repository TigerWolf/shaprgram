class ProjectsController < ApplicationController

  def index
    @projects = Project.all
  end

  def show
    @project = find_project
  end

  def create
    project = Project.new(project_params)
    project.save!
    redirect_to project
  end

  def update
    project = find_project
    if project.update_attributes(project_params)
      flash[:notice] = 'Project updated.'
    else
      flash[:notice] = 'Could not update project.'
    end

    redirect_to :back
  end

  def export
    project = find_project
    @items = project.items.includes(:photos)
    respond_to do |format|
      format.json { render json: @items, include: :photos }
      format.xml { render xml: @items, include: :photos}
      format.csv { render csv: @items, include: :photos}
    end
  end

  private

    def project_params
      params.require(:project).permit(:name, :data_source_uri, :administrative_boundry_id)
    end

    def find_project
      Project.find(params[:id])
    end


end
