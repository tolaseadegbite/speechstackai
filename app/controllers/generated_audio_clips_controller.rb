class GeneratedAudioClipsController < DashboardController
  def new
    @service_type = params[:service_type]
    # THE FIX: Order the records by created_at DESC before grouping them.
    @generated_audio_clips = current_user.generated_audio_clips
                                       .includes(:voice)
                                       .order(created_at: :desc)
                                       .group_by { |audio| audio.created_at.to_date }
    @generated_audio_clip = GeneratedAudioClip.new
    @voices = Voice.includes(:languages).order(:name)
  end

  def create
    @generated_audio_clip = current_user.generated_audio_clips.new(audio_clip_params)
    @service_type = params[:generated_audio_clip][:service_type] # Use @service_type for consistency

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
      # THE FIX: Also apply the ordering here for the validation error case.
      @generated_audio_clips = current_user.generated_audio_clips
                                       .includes(:voice)
                                       .order(created_at: :desc)
                                       .group_by { |audio| audio.created_at.to_date }
      @voices = Voice.includes(:languages).order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def audio_clip_params
    params.require(:generated_audio_clip).permit(:text, :voice_id, :service_type)
  end
end