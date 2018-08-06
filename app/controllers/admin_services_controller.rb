class AdminServicesController < ApplicationController
  before_action :ensure_admin

  def admin
  end

  def ensure_admin
    unless current_user.try(:admin?)
      redirect_to root_path, alert: 'Current user does not have administrative privilages.'
    end
  end
end
