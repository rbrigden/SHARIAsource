class Admin::UsersController < AdminController
  before_filter :ensure_editor!
  before_filter :fetch_user, only: [:edit, :update]

  def index
    @users = User.order(:last_name_without_articles)
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    random_pass = SecureRandom.urlsafe_base64(24)
    @user = User.new permitted_params
    @user.password = @user.password_confirmation = random_pass
    if @user.save
      flash[:notice] = 'Account created successfully'
      @user.send_reset_password_instructions
      redirect_to admin_users_path
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      render :new
    end
  end

  def update
    @user.update permitted_params
    flash[:notice] = 'Account updated successfully'
    redirect_to admin_users_path
  end

  protected

  def permitted_params
    params.require(:user).permit(:is_editor, :requires_approval, :first_name,
                                 :last_name, :about, :avatar, :email,
                                 :collaborator_id, :parent_id)
  end

  def fetch_user
    @user = User.find params[:id]
  end
end
