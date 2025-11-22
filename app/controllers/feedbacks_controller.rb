class FeedbacksController < DashboardController
  before_action :set_feedback, only: %i[show edit update destroy]
  before_action :authorize_admin!, only: %i[edit update destroy]

  def index
    base_query = if current_user.admin?
                   Feedback.all
                 else
                   current_user.feedbacks
                 end

    @q = base_query.ransack(params[:q])

    feedbacks_query = @q.result(distinct: true)

    if current_user.admin?
      @users = User.where(id: feedbacks_query.select(:user_id)).order(email: :asc)
    end

    @feedbacks = feedbacks_query.includes(:user).order(created_at: :desc)

    @pagy, @feedbacks = pagy_keyset(@feedbacks, limit: 21)

    @feedback = Feedback.new
  end

  def show
  end

  def new
    if params[:generated_audio_clip_id]
      audio_clip = current_user.generated_audio_clips.find(params[:generated_audio_clip_id])
      @feedback = Feedback.new(
        generated_audio_clip_id: audio_clip.id,
        service: audio_clip.service
      )
    elsif params[:service].present? && Feedback.services.key?(params[:service])
      @feedback = Feedback.new(service: params[:service])
    else
      @feedback = Feedback.new
    end
  end

  def edit
  end

  def create
    @feedback = current_user.feedbacks.new(feedback_params)

    respond_to do |format|
      if @feedback.save
        flash.now[:notice] = "Feedback was successfully submitted."
        format.turbo_stream
      else
        flash.now[:alert] = @feedback.errors.full_messages.to_sentence
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash_messages", partial: "layouts/shared/flash"),
                 status: :unprocessable_entity
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @feedback.update(feedback_params)
        flash.now[:notice] = "Feedback was successfully updated."
        format.turbo_stream
      else
        flash.now[:alert] = @feedback.errors.full_messages.to_sentence
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash_messages", partial: "layouts/shared/flash"),
                 status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @feedback.destroy!
    respond_to do |format|
      format.turbo_stream
      flash.now[:notice] = "Feedback was successfully destroyed."
      format.html { redirect_to feedbacks_url, status: :see_other, notice: "Feedback was successfully destroyed." }
    end
  end

  private

  def set_feedback
    if current_user.admin?
      @feedback = Feedback.find(params[:id])
    else
      @feedback = current_user.feedbacks.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to feedbacks_url, alert: "Feedback not found."
  end

  def feedback_params
    params.require(:feedback).permit(:comment, :rating, :feedback_type, :service, :generated_audio_clip_id)
  end

  def authorize_admin!
    return if current_user.admin?

    unless @feedback.user == current_user
      redirect_to feedbacks_url, alert: "You are not authorized to perform this action."
    end
  end
end