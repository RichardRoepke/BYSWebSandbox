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

  def update
    puts '============================================================='
    puts params.inspect
    puts '============================================================='
    #if @user.update_attributes(user_params)
    #  flash[:success] = "Profile updated"
    #  redirect_to edit_admin_user_path(@user)
    #else
    #  puts 'GAH'
    #end
  end
end