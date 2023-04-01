class UsersController < ApplicationController
 
  before_action :set_user, only: [:show ,:edit, :update]
 
  def index
      @q = User.ransack(params[:q])
      #@users = @q.result(distinct: true).order(created_at: :desc)
      @users = @q.result.includes(:roles)
      @users = @users.joins(:roles).where('roles.id = ?', params[:role_eq]) if params[:role_eq].present?
      @pagy, @users = pagy(@users)
      authorize @users
  end
  
  def show
  end
  
  def edit
    authorize @user 
  end

  def update
    authorize @user
    
    if @user.update(user_params)
      redirect_to users_path, notice: 'User roles were successfully updated.'
    else
      render :edit
    end
  end
  private

  def set_user
    @user = User.friendly.find(params[:id])
  end

 def has_only_one_admin
    if @user.has_role?(:admin) && @user.roles.count == 1
      return true
    end
    false
  end

  def user_params
    params.require(:user).permit({ role_ids: [] })
  end
  #def create
    # Create the user from params
   # @user = User.new(user_params)
    #if @user.save
      # Deliver the signup email
     # UserNotifierMailer.send_signup_email(@user).deliver
      #redirect_to(@user, :notice => 'User created')
    #else
     # render :action => 'new'
    #end
  #end
  
  #private
  
  #def user_params
   # params.require(:user).permit(:name, :email, :login)
  #end
end
