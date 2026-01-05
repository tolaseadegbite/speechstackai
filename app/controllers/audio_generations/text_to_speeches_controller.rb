module AudioGenerations
  class TextToSpeechesController < DashboardsController
    def index
      @q = current_user.text_to_speech_clips.ransack(params[:q])

      # Paginate the ActiveRecord relation
      @pagy, @generated_audio_clips = pagy(@q.result(distinct: true)
                                            .includes(:voice)
                                            .order(created_at: :desc))

      # Create the grouped hash specifically for the history list partial
      @grouped_clips = @generated_audio_clips.group_by { |clip| clip.created_at.to_date }

      @clip = TextToSpeechClip.new
      @voices = Voice.includes(:languages).order(:name)
    end


    def create
      @clip = current_user.text_to_speech_clips.new(tts_params)

      if @clip.save
        GenerateAudioClipJob.perform_later(@clip)
        flash.now[:notice] = "Generating speech..."

        # We need to reload the voices for the re-render if using Turbo
        @voices = Voice.includes(:languages).order(:name)
        respond_to { |format| format.turbo_stream }
      else
        @voices = Voice.includes(:languages).order(:name)
        flash.now[:alert] = @clip.errors.full_messages.to_sentence
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_messages", partial: "layouts/shared/flash") }
        end
      end
    end

    private

    def tts_params
      params.require(:text_to_speech_clip).permit(:text, :voice_id)
    end
  end
end
