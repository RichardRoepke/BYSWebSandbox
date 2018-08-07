class Admin::UserController < AdminServicesController
  # Inherits before_action ensure_admin from AdminServicesController so no
  # need to double-check for adminhood here.

  def new
    @user = User.new(new_user_params)
    if @user.save
      flash[:success] = 'User made.'
      redirect_to admin_path
    else
      @user.errors.full_messages.each do |error|
        puts 'ERROR: ' + error.to_s
        flash[error.to_sym] = error
      end
      redirect_to admin_newuser_path(params.require(:user).permit(:email, :security, :admin))
    end
  end

  def index
    @users = User.all.paginate(page: params[:page], per_page: 30)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def destroy
    user = User.find(params[:id])

    if user == current_user
      flash[:success] = "Can't delete currently logged in user."
    else
      user.destroy
      flash[:success] = "User deleted."
    end

    redirect_back(fallback_location: root_path)
  end

  def update
    if params[:user].present?
      @user = User.find(params[:user][:id])

      if @user.update(user_params)
        flash[:success] = "Profile updated."
        redirect_to admin_user_index_path
      else
        flash[:alert] = 'Profile failed to update.'
        @user.errors.full_messages.each do |error|
          flash[error.to_sym] = error
        end
        redirect_to edit_admin_user_path(@user.id)
      end
    end
  end

  def promote
    # I have no idea why user.id is turned into :format instead of :id for this
    # function. Perhaps because it was declared outside of devise/the model?
    user = User.find(params[:format])
    user.admin = true
    if user.save
      flash[:success] = "User has been promoted to administrator."
    else
      user.errors.full_messages.each do |error|
        flash[error.to_sym] = error
      end
    end

    redirect_back(fallback_location: root_path)
  end

  def demote
    # I have no idea why user.id is turned into :format instead of :id for this
    # function. Perhaps because it was declared outside of devise/the model?
    user = User.find(params[:format])
    user.admin = false
    if user.save
      flash[:success] = "User has been demoted from administrator."
    else
      user.errors.full_messages.each do |error|
        flash[error.to_sym] = error
      end
    end

    redirect_back(fallback_location: root_path)
  end

  def user_params
    if params[:user][:password].present? && params[:user][:password_confirmation].present?
      params.require(:user).permit(:security, :password, :password_confirmation)
    else
      params.require(:user).permit(:security)
    end
  end

  def new_user_params
    params.require(:user).permit(:email, :security, :admin, :password, :password_confirmation)
  end
end