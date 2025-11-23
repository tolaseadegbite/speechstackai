class InvitationsController < DashboardsController
  def new
    @user = User.new
  end

  def create
    @user = User.create_with(user_creation_defaults).find_or_initialize_by(email: user_params_from_form[:email])

    respond_to do |format|
      if @user.save
        send_invitation_instructions

        format.turbo_stream do
          flash.now[:notice] = "An invitation email has been sent to #{@user.email}"
          render turbo_stream: [
            turbo_stream.update("flash_messages", partial: "layouts/shared/flash"),
            turbo_stream.replace("new_invitation_form", partial: "form", locals: { user: User.new })
          ]
        end

        format.html { redirect_to new_invitation_path, notice: "An invitation email has been sent to #{@user.email}" }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  private
    def user_params_from_form
      params.require(:user).permit(:email)
    end

    def user_creation_defaults
      email = user_params_from_form[:email]
      name_from_email = email.split('@').first.gsub(/[^a-zA-Z0-9]/, ' ').titleize

      {
        password: SecureRandom.base58,
        verified: true,
        name: name_from_email
      }
    end

    def send_invitation_instructions
      UserMailer.with(user: @user).invitation_instructions.deliver_later
    end
end