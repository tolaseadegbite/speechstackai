class GeneratedAudioClipsController < DashboardController
  def new
    @service_type = params[:service_type]
    @generated_audio_clips = current_user.generated_audio_clips.order(created_at: :desc)
    @generated_audio_clip = GeneratedAudioClip.new
  end

  def create
    @generated_audio_clip = current_user.generated_audio_clips.new(audio_clip_params)
    @service_type = params[:generated_audio_clip][:service_type] # Use @service_type for consistency

    if @generated_audio_clip.save
      case @service_type
      when "text_to_speech"
        # THE FIX: We set an instance variable with the correct form ID.
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
      respond_to do |format|
        format.turbo_stream
      end
    else
      # The failure path is already perfect.
      render :new, status: :unprocessable_entity
    end
  end

  private

  def audio_clip_params
    # THE FIX: Permit all possible attributes for all your services.
    params.require(:generated_audio_clip).permit(
      :text, :voice, :service_type
    )
  end
end
