class AdminServicesController < ApplicationController
  before_action :ensure_admin

  def admin
  end

  def ensure_admin
    unless current_user.try(:admin?)
      if current_user.present?
        redirect_to root_path, alert: 'Current user does not have administrative privilages.'
      else
        redirect_to new_user_session_path, alert: 'You need to sign in before continuing.'
      end
    end
  end
end
