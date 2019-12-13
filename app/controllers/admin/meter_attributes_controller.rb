module Admin
  class MeterAttributesController < ApplicationController
    load_and_authorize_resource :school_group

    def index
      @meter_attributes = @school_group.meter_attributes.active
      @deleted_meter_attributes = @school_group.meter_attributes.deleted
      @available_meter_attributes = MeterAttributes.all
    end

    def new
      @meter_attribute_type = MeterAttributes.all[params[:type].to_sym]
    end

    def create
      @school_group.meter_attributes.create!(
        attribute_type: params[:attribute][:type],
        reason: params[:attribute][:reason],
        input_data: params[:attribute][:root],
        meter_type: params[:attribute][:meter_type],
        created_by: current_user
      )
      redirect_to admin_school_group_meter_attributes_path(@school_group)
    end

    def show
      @meter_attribute = @school_group.meter_attributes.find(params[:id])
      authorize! :show, @meter_attribute
    end

    def edit
      @meter_attribute = @school_group.meter_attributes.find(params[:id])
      @meter_attribute_type = @meter_attribute.meter_attribute_type
      authorize! :edit, @meter_attribute
      @input_data = @meter_attribute.input_data
    end

    def update
      meter_attribute = @school_group.meter_attributes.find(params[:id])
      authorize! :edit, @meter_attribute
      new_attribute = @school_group.meter_attributes.create!(
        attribute_type: meter_attribute.attribute_type,
        reason: params[:attribute][:reason],
        input_data: params[:attribute][:root],
        meter_type: params[:attribute][:meter_type],
        created_by: current_user
      )
      meter_attribute.update!(replaced_by: new_attribute)
      redirect_to admin_school_group_meter_attributes_path(@school_group)
    end

    def destroy
      meter_attribute = @school_group.meter_attributes.find(params[:id])
      authorize! :delete, meter_attribute
      meter_attribute.update!(deleted_by: current_user)
      redirect_to admin_school_group_meter_attributes_path(@school_group)
    end
  end
end