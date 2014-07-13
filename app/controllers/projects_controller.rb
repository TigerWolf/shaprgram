class ProjectsController < ApplicationController
  def list
    @project = Project.new
  end

  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
  end

  def create
    project = Project.new(project_params)
    project.save!
    redirect_to project
  end

  def update
    project = Project.find(params[:id])
    if project.update_attributes(project_params)
      flash[:notice] = 'Project updated.'
    else
      flash[:notice] = 'Could not update project.'
    end

    redirect_to :back
  end
  
  private

    def project_params
      params.require(:project).permit(:name, :data_source_uri, :administrative_boundry_id)
    end

end
