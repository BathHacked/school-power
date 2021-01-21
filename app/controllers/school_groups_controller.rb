class SchoolGroupsController < ApplicationController
  load_and_authorize_resource

  skip_before_action :authenticate_user!, except: :index

  def index
    @school_groups = SchoolGroup.by_name
  end

  def show
  end

  def map
    gon.OSDATAHUB_API_KEY = ENV['OSDATAHUB_API_KEY']
    gon.MAPBOX_API_KEY = ENV['MAPBOX_API_KEY']

    @schools = @school_group.schools.visible.order(name: :asc)
    respond_to do |format|
      format.html
      format.json { render json: Maps::Features.new(@schools).as_json, status: :ok }
    end
  end
end
