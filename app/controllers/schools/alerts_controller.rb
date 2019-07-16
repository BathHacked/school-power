# frozen_string_literal: true

module Schools
  class AlertsController < ApplicationController
    load_and_authorize_resource :school

    def show
      @alert = Alert.find(params[:id])
      authorize! :read, @alert
    end
  end
end
