module KeyStageFilterable
  extend ActiveSupport::Concern

private

  def key_stage_filter_params
    params.permit(key_stage: { key_stage_ids: [] })
  end

  def selected_key_stage_filters
    key_stage = key_stage_filter_params[:key_stage]

    if key_stage.nil?
      default_key_stage_filters
    else
      filters = key_stage[:key_stage_ids]
      KeyStage.where(id: filters)
    end
  end

  def default_key_stage_filters
    if @school
      @school.key_stages
    elsif current_user.nil? || current_user.school.nil?
      KeyStage.order(:name)
    else
      # Set for the school defaults
      current_user.school.key_stages
    end
  end
end
