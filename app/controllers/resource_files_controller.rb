class ResourceFilesController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    @resource_file_types = ResourceFileType.order(:position)
    @other_resource_files = ResourceFile.where(resource_file_type_id: nil).order(:title)
  end
end
