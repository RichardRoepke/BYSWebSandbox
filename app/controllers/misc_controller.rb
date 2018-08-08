class MiscController < ApplicationController
  include ApiHelper

  before_action :authenticate_user!

  def text_parse
    @output = {}

    if params[:input_form].present?
      @set = params[:input_form]

      if params[:user_action].present?
        if params[:user_action] == 'Submit XML'
          @output = api_call('https://54.197.134.112:3400/' + @set[:request_ID], @set[:input], 'XML')
        elsif params[:user_action] == 'Submit JSON'
          @output = api_call('https://54.197.134.112:3400/' + @set[:request_ID], @set[:input], 'JSON')
        end
      end
    else
      @set = {request_ID: "unittypeinfo"}
    end
  end

  def account
    if params[:input_form].present?
      @set = params[:input_form]
      if params[:commit] == 'Update Account'
        update_account(params[:input_form][:password], params[:input_form][:old_password])
      end
    else
      @set = {}
      @set[:security] = current_user.security if current_user.security.present?
    end
  end

  private

  def update_account(new_password, old_password)
    # If the user isn't changing their password or if their old password is present and valid.
    if new_password.blank? || current_user.valid_password?(old_password)
      if current_user.update(user_params)
        flash[:success] = 'Your changes have been successfully updated.'
        bypass_sign_in(current_user) # No need to log in again when the user updates their password.
        redirect_to account_path
      else
        flash.now[:alert] = 'Update failed.'
        current_user.errors.full_messages.each do |error|
          flash.now[error.to_sym] = error
        end
      end
    else
      # Only renders if a new password was provided but the current password failed validation.
      flash.now[:alert] = 'Update failed.'
      flash.now[:old] = 'Current Password failed validation. Password was not changed.'
    end
  end

  def user_params
    if params[:input_form][:password].present?
      params.require(:input_form).permit(:security, :password, :password_confirmation)
    else
      params.require(:input_form).permit(:security)
    end
  end
end
