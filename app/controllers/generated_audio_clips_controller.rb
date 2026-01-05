class GeneratedAudioClipsController < DashboardsController
  before_action :set_generated_audio_clip, only: %i[ destroy audio_url ]

  # OPTIONAL: Keep this if you want a "Master History" page showing all types
  def index
    @q = current_user.generated_audio_clips.ransack(params[:q])
    @generated_audio_clips = @q.result(distinct: true)
                              .includes(:voice)
                              .order(created_at: :desc)
                              .group_by { |audio| audio.created_at.to_date }
  end

  def destroy
    @date_to_check = @generated_audio_clip.created_at.to_date
    @generated_audio_clip.destroy

    # UI Logic for removing date headers
    beginning_of_the_day = @date_to_check.in_time_zone.beginning_of_day
    end_of_the_day = @date_to_check.in_time_zone.end_of_day

    # Check existence on the PARENT class to cover all types
    @remove_date_group = !current_user.generated_audio_clips
                                      .where(created_at: beginning_of_the_day..end_of_the_day)
                                      .exists?

    respond_to do |format|
      format.turbo_stream
      # Fallback redirect checks referer, or goes to global list
      format.html { redirect_back fallback_location: generated_audio_clips_path, notice: "Deleted." }
    end
  end

  def audio_url
    if @generated_audio_clip&.s3_key.present?
      url = presigned_s3_url(@generated_audio_clip.s3_key)
      render json: { url: url }
    else
      render json: { error: "No audio file found." }, status: :not_found
    end
  end

  private

  def set_generated_audio_clip
    @generated_audio_clip = current_user.generated_audio_clips.find(params[:id])
  end
end
