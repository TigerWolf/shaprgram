class ProjectsController < ApplicationController
  def list
    @project = Project.new
  end
end
