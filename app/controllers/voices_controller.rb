class VoicesController < DashboardController
  include S3Helper

  before_action :set_voice, only: %i[ show edit update destroy audio_url ]
  before_action :set_languages, only: %i[ index show new create edit update ]
  
  # Ensure only admin users can access modification actions
  before_action :authorize_admin!, only: %i[ new create edit update destroy ]

  # GET /voices or /voices.json
  def index
    @voices = Voice.includes(:languages, :user).order(id: :desc)
    # The 'new' voice instance is only for the form, which will be hidden for non-admins.
    # A better approach for the view would be to conditionally render the form.
    @voice = Voice.new 
  end

  # GET /voices/1 or /voices/1.json
  def show
  end

  # GET /voices/new
  # This action is now protected by authorize_admin!
  def new
    @voice = Voice.new
  end

  # GET /voices/1/edit
  # This action is now protected by authorize_admin!
  def edit
  end

  # POST /voices or /voices.json
  # This action is now protected by authorize_admin!
  def create
    # Since only an admin can create, the voice will be associated with the current admin user.
    @voice = current_user.voices.new(voice_params)

    respond_to do |format|
      if @voice.save
        flash.now[:notice] = "Voice was successfully created."
        format.turbo_stream
      else
        flash.now[:alert] = @voice.errors.full_messages.to_sentence
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash_messages", partial: "layouts/shared/flash"),
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /voices/1 or /voices/1.json
  # This action is now protected by authorize_admin!
  def update
    respond_to do |format|
      if @voice.update(voice_params)
        flash.now[:notice] = "Voice was successfully updated."
        format.turbo_stream
      else
        flash.now[:alert] = @voice.errors.full_messages.to_sentence
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash_messages", partial: "layouts/shared/flash"),
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /voices/1 or /voices/1.json
  # This action is now protected by authorize_admin!
  def destroy 
    @voice.destroy!
    respond_to do |format|
      format.turbo_stream
      flash.now[:notice] = "Voice was successfully deleted."
      format.html { redirect_to voices_url, status: :see_other, notice: "Voice was successfully destroyed." }
    end
  end

  # GET /voices/:id/audio_url
  def audio_url
    if @voice.s3_key.present?
      url = presigned_s3_url(@voice.s3_key)
      render json: { url: url }
    else
      render json: { error: "No audio file associated with this voice." }, status: :not_found
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_voice
    @voice = Voice.find(params.expect(:id))
  end

  def set_languages
    @languages = Language.order(:name)
  end

  # Only allow a list of trusted parameters through.
  def voice_params
    params.expect(voice: [ :name, :gender, :visibility, :description, :s3_key, language_ids: [] ])
  end
  
  # New authorization method to restrict access to admins.
  def authorize_admin!
    unless current_user.admin?
      # Redirect non-admins and show an alert.
      redirect_to voices_url, alert: "You are not authorized to perform this action."
    end
  end
end
