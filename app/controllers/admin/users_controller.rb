module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :edit, :update ]

    def index
      # Using simple Active Record for now.
      # If you have Pagy included globally, you can wrap this.
      @users = User.order(created_at: :desc)
    end

    def show
      @clips = @user.generated_audio_clips.includes(:voice).order(created_at: :desc)

      # Calculate stats for the admin view
      @current_credits = @user.credits
      @total_clips = GeneratedAudioClip.count
      @total_credits = User.sum(:credits)
    end

    def edit; end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:credits, :admin)
    end
  end
end
