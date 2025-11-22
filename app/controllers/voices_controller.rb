class VoicesController < DashboardController
  include S3Helper

  before_action :set_voice, only: %i[ show edit update destroy audio_url ]
  before_action :set_languages, only: %i[ index show new create edit update ]
  
  before_action :authorize_admin!, only: %i[ new create edit update destroy ]

  def index
    @voices = Voice.includes(:languages, :user).order(id: :desc)
    @voice = Voice.new 
  end

  def show
  end

  def new
    @voice = Voice.new
  end

  def edit
  end

  def create
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

  def destroy 
    @voice.destroy!
    respond_to do |format|
      format.turbo_stream
      flash.now[:notice] = "Voice was successfully deleted."
      format.html { redirect_to voices_url, status: :see_other, notice: "Voice was successfully destroyed." }
    end
  end

  def audio_url
    if @voice.s3_key.present?
      url = presigned_s3_url(@voice.s3_key)
      render json: { url: url }
    else
      render json: { error: "No audio file associated with this voice." }, status: :not_found
    end
  end

  private

  def set_voice
    @voice = Voice.find(params.expect(:id))
  end

  def set_languages
    @languages = Language.order(:name)
  end

  def voice_params
    params.expect(voice: [ :name, :gender, :visibility, :description, :s3_key, language_ids: [] ])
  end
  
  def authorize_admin!
    unless current_user.admin?
      redirect_to voices_url, alert: "You are not authorized to perform this action."
    end
  end
end
