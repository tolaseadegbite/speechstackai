class SpeechSynthesisController < DashboardController
  # GET /text-to-speech
  def text_to_speech
    @generated_audio_clips = current_user.generated_audio_clips.order(created_at: :desc)
    # This is for the form builder
    @generated_audio_clip = GeneratedAudioClip.new
  end

  # POST /text-to-speech
  def create
    @generated_audio_clip = current_user.generated_audio_clips.new(audio_clip_params)

    if @generated_audio_clip.save
      GenerateAudioClipJob.perform_later(@generated_audio_clip)

      flash.now[:notice] = "Your audio is being generated and will appear in your history shortly."
      respond_to do |format|
        format.turbo_stream
      end
    else
      # For validation failures, we'll still render an update to the error messages div
      render turbo_stream: turbo_stream.update("form-errors",
        partial: "layouts/shared/error_messages",
        locals: { object: @generated_audio_clip }), status: :unprocessable_entity
    end
  end

  private

  def audio_clip_params
    params.require(:generated_audio_clip).permit(:text, :voice)
  end
end
