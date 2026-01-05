module AudioGenerations
  class VoiceConversionsController < ApplicationController
    def index
      # 1. Scoped Search: Only finds VoiceConversionClip records
      @q = current_user.voice_conversion_clips.ransack(params[:q])

      @generated_audio_clips = @q.result(distinct: true)
                                .order(created_at: :desc)
                                .group_by { |audio| audio.created_at.to_date }

      # 2. Form Setup (VC doesn't need voices list, maybe just file upload)
      @clip = VoiceConversionClip.new
    end

    def create
      @clip = current_user.voice_conversion_clips.new(vc_params)

      if @clip.save
        # VoiceConversionJob.perform_later(@clip)
        flash.now[:notice] = "Converting voice..."
        respond_to { |format| format.turbo_stream }
      else
        flash.now[:alert] = @clip.errors.full_messages.to_sentence
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("flash_messages", partial: "layouts/shared/flash") }
        end
      end
    end

    private

    def vc_params
      # Example params for VC
      params.require(:voice_conversion_clip).permit(:original_voice_s3_key, :text)
    end
  end
end
