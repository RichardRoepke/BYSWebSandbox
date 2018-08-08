class AdminServicesController < ApplicationController
  before_action :ensure_admin

  def admin
  end

  def new_user
    @user = User.new
    # Sets up user fields if values are present in params.
    # Should only occur if creating a new user failed.
    @user.email = params[:email]
    @user.security = params[:security]
    @user.admin = params[:admin]
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
