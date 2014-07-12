class ProjectsController < ApplicationController
  def list
    @project = Project.new
  end

  def index
    @projects = Project.all
  end

  def show
    @projects = Project.find(params[:id])
  end

  def create
    require 'net/http'

    uri = URI(params[:data_source_uri])
    response = Net::HTTP.get_response(uri)

    temp_file = Tempfile.new('shapefile')
    temp_file.write(response.body)

    project = Project.new(project_params)
    project.slug = Digest::SHA1.hexdigest([Time.now, rand].join)[0...8].upcase
    project.save!
    redirect_to project
  end

  def new
    # TODO Refactor to service object?
    require 'net/http'

    uri = URI(params[:url])
    response = Net::HTTP.get_response(uri)

    temp_file = Tempfile.new('shapefile')
    temp_file.write(response.body)

    project = Project.new(name: params[:name], url: params[:url])

    # TODO Guess type and load a CSVFileReader if appropriate.


    # TODO Refactor to an iterator so it's a lot easier to deal with a stream
    #
    # Either we do:
    #
    # reader = ShapefileReader.new
    # records = reader.parse(temp_file.path) # gunzip?

    # record = records.first
    #
    # and
    #
    # create_table project.uniq_table! do |t|
    #   record.attributes.each_with_key do |k, v|
    #     t.string k # TODO v.kind_of X = column type Y
    #   end
    #   t.geom :the_geom
    # end
    # and iterate doing a bit of CRUD
    #
    # or http://www.iknuth.com/2010/05/bulk-loading-shapefiles-into-postgis/
    #
    # Need transformations from X to Y?
    # ogr2ogr -t_srs EPSG:4326 -a_srs EPSG:4326 -f "ESRI Shapefile" Bridges_pdx_4326.shp Bridges_pdx.shp
    #
    # shp2pgsql -s 4326 -d -g the_geom #{temp_file.path} #{project.make_some_uniq_table_name} | psql #{Rails.config.commandlineify_wheeeee!}
    #

    # project.save!

    redirect_to "/projects/1/list"
  end

  private
  def project_params
    params.require(:project).permit(:name, :data_source_uri)
  end
end
