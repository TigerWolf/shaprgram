class WelcomeController < ApplicationController
  def index
    @project = Project.new
  end
end
