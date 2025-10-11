class FeedbacksController < DashboardController
  before_action :set_feedback, only: %i[show edit update destroy]
  before_action :authorize_admin!, only: %i[edit update destroy]

  # GET /feedbacks or /feedbacks.json
  # Prepares a list of feedbacks based on user role and a new object for the form.
  def index
    # 1. Determine the base query based on user role
    base_query = if current_user.admin?
                   Feedback.all
                 else
                   current_user.feedbacks
                 end

    # 2. Initialize Ransack search object with params[:q]
    @q = base_query.ransack(params[:q])

    # 3. Get the base filtered query from Ransack.
    feedbacks_query = @q.result(distinct: true)

    # 4. Fetch users for the filter dropdown (only for admins)
    if current_user.admin?
      @users = User.where(id: feedbacks_query.select(:user_id)).order(email: :asc)
    end

    # 5. Build the final query for displaying the feedbacks
    @feedbacks = feedbacks_query.includes(:user).order(created_at: :desc)

    # 6. Apply pagination to the final, sorted results.
    @pagy, @feedbacks = pagy_keyset(@feedbacks, limit: 21)

    # 7. Prepare a new Feedback object for a form, if needed.
    @feedback = Feedback.new
  end

  # GET /feedbacks/1 or /feedbacks/1.json
  def show
    # Authorization is handled by set_feedback
  end

  # GET /feedbacks/new
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

  # GET /feedbacks/1/edit
  def edit
    # Authorization is handled by set_feedback and authorize_admin!
  end

  # POST /feedbacks or /feedbacks.json
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

  # PATCH/PUT /feedbacks/1 or /feedbacks/1.json
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

  # DELETE /feedbacks/1 or /feedbacks/1.json
  def destroy
    @feedback.destroy!
    respond_to do |format|
      format.turbo_stream
      flash.now[:notice] = "Feedback was successfully destroyed."
      format.html { redirect_to feedbacks_url, status: :see_other, notice: "Feedback was successfully destroyed." }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_feedback
    if current_user.admin?
      @feedback = Feedback.find(params[:id])
    else
      @feedback = current_user.feedbacks.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to feedbacks_url, alert: "Feedback not found."
  end

  # Only allow a list of trusted parameters through.
  def feedback_params
    params.require(:feedback).permit(:comment, :rating, :feedback_type, :service, :generated_audio_clip_id)
  end

  # Authorization method to check for admin privileges.
  def authorize_admin!
    return if current_user.admin?

    # Non-admins can only edit or delete their own feedback.
    unless @feedback.user == current_user
      redirect_to feedbacks_url, alert: "You are not authorized to perform this action."
    end
  end
end