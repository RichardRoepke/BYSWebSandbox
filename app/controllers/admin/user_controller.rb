class Admin::UserController < AdminServicesController
  # Inherits before_action ensure_admin from AdminServicesController so no
  # need to double-check for adminhood here.

  def new
    @user = User.new(new_user_params)
    if @user.save
      flash[:success] = 'User made.'
      redirect_to admin_path
    else
      flash[:alert] = 'User could not be made.'
      @user.errors.full_messages.each do |error|
        flash[error.to_sym] = error
      end
      # Returning to the page which requested the new user.
      redirect_to admin_newuser_path(params.require(:user).permit(:email, :security, :admin))
    end
  end

  def index
    @users = User.all.paginate(page: params[:page], per_page: 30)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if params[:user].present?
      @user = User.find(params[:id])

      if @user.update(user_params)
        flash[:success] = "Profile updated."
        redirect_to admin_user_index_path
      else
        flash[:alert] = 'Profile failed to update.'
        @user.errors.full_messages.each do |error|
          flash[error.to_sym] = error
        end
        redirect_back(fallback_location: root_path)
      end
    end
  end

  def destroy
    user = User.find(params[:id])
      if user == current_user
        flash[:alert] = "Can't delete currently logged in user."
      else
        if user.destroy
          flash[:success] = "User deleted."
        else
          flash[:alert] = 'User could not be deleted.'
          user.errors.full_messages.each do |error|
            flash[error.to_sym] = error
          end if users.errors.present?
        end
      end

    redirect_back(fallback_location: root_path)
  rescue => exception
    flash[:alert] = 'An exception occured.'
    flash[:exception] = exception.inspect
    redirect_back(fallback_location: root_path)
  end

  def promote
    # I have no idea why user.id is turned into :format instead of :id for this
    # function. Perhaps because it was declared outside of devise/the model?
    change_admin_status(params[:format], true, "User has been promoted to administrator.")
    redirect_back(fallback_location: root_path)
  end

  def demote
    # I have no idea why user.id is turned into :format instead of :id for this
    # function. Perhaps because it was declared outside of devise/the model?
    change_admin_status(params[:format], false, "User has been demoted from administrator.")
    redirect_back(fallback_location: root_path)
  end

  private

  def change_admin_status(id, status, message)
    user = User.find(id)

    if user == current_user
      flash[:alert] = 'Cannot change admin status of the current user.'
    else
      user.admin = status
      if user.save
        flash[:success] = message
      else
        user.errors.full_messages.each do |error|
          flash[error.to_sym] = error
        end
      end
    end
  end

  def user_params
    if params[:user][:password].present?
      params.require(:user).permit(:security, :password, :password_confirmation)
    else
      params.require(:user).permit(:security)
    end
  end

  def new_user_params
    params.require(:user).permit(:email, :security, :admin, :password, :password_confirmation)
  end
end