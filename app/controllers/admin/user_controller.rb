class Admin::UserController < AdminServicesController
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
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to admin_user_index_path
  end

  def update
    if params[:user].present?
      @user = User.find(params[:user][:id])

      if @user.update(user_params)
        flash[:success] = "Profile updated"
        redirect_to admin_user_index_path
      else
        flash[:alert] = 'Profile failed to update'
        @user.errors.full_messages.each do |error|
          puts 'ERROR: ' + error.to_s
          flash[error.to_sym] = error
        end
        redirect_to edit_admin_user_path(@user.id)
      end
    end
  end

  def user_params
    if params[:user][:password].present? && params[:user][:password_confirmation].present?
      params.require(:user).permit(:email, :security, :password, :password_confirmation)
    else
      params.require(:user).permit(:email, :security)
    end
  end
end