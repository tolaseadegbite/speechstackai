module Admin
  class GeneratedAudioClipsController < BaseController
    def index
      @clips = GeneratedAudioClip.includes(:user, :voice).order(created_at: :desc)
    end

    def destroy
      @clip = GeneratedAudioClip.find(params[:id])
      @clip.destroy
      redirect_to admin_generated_audio_clips_path, notice: "Clip removed."
    end
  end
end
