class GeneratedAudioClipsController < DashboardsController
  before_action :set_generated_audio_clip, only: %i[ destroy audio_url ]

  def new
    @service_type = params[:service_type]

    @q = current_user.generated_audio_clips.ransack(params[:q])

    @generated_audio_clips = @q.result(distinct: true)
                              .includes(:voice)
                              .order(created_at: :desc)
                              .group_by { |audio| audio.created_at.to_date }

    @generated_audio_clip = GeneratedAudioClip.new
    @voices = Voice.includes(:languages).order(:name)
  end

  def create
    @generated_audio_clip = current_user.generated_audio_clips.new(audio_clip_params)
    @service_type = params[:generated_audio_clip][:service_type]

    if @generated_audio_clip.save
      case @service_type
      when "text_to_speech"
        @form_id = "text_to_speech_form"
        GenerateAudioClipJob.perform_later(@generated_audio_clip)
      when "voice_changer"
        @form_id = "voice_changer_form"
        # VoiceChangerJob.perform_later(@generated_audio_clip)
      when "sound_effects"
        @form_id = "sound_effects_form"
        # SoundEffectsJob.perform_later(@generated_audio_clip)
      end

      flash.now[:notice] = "Your audio is being generated and will appear in your history shortly."
      @voices = Voice.includes(:languages).order(:name)

      respond_to do |format|
        format.turbo_stream
      end
    else
      flash.now[:alert] = @generated_audio_clip.errors.full_messages.to_sentence

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash_messages", partial: "layouts/shared/flash"),
                 status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    # @generated_audio_clip = current_user.generated_audio_clips.find(params[:id])
    @context = params[:context] || :desktop
    @date_to_check = @generated_audio_clip.created_at.to_date
    @generated_audio_clip.destroy

    beginning_of_the_day = @date_to_check.in_time_zone.beginning_of_day
    end_of_the_day = @date_to_check.in_time_zone.end_of_day

    @remove_date_group = !current_user.generated_audio_clips
                                      .where(created_at: beginning_of_the_day..end_of_the_day)
                                      .exists?

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to new_generated_audio_clip_path, notice: "Audio clip was successfully deleted." }
    end
  end

  def audio_url
    if @generated_audio_clip&.s3_key.present?
      url = presigned_s3_url(@generated_audio_clip.s3_key)
      render json: { url: url }
    else
      render json: { error: "No audio file associated with this clip." }, status: :not_found
    end
  end

  private

  def audio_clip_params
    params.require(:generated_audio_clip).permit(:text, :voice_id, :service_type)
  end

  def set_generated_audio_clip
    @generated_audio_clip = current_user.generated_audio_clips.find(params[:id])
  end
end
