class FeedbacksController < DashboardController
  before_action :set_feedback, only: %i[ show edit update destroy ]

  # GET /feedbacks or /feedbacks.json
  # Prepares a list of all feedbacks for an admin view and a new object for the form.
  def index
    # 1. Initialize Ransack search object with params[:q]
    @q = Feedback.ransack(params[:q])

    # 2. Get the base filtered query from Ransack.
    #    Note: No .order() is applied here yet.
    feedbacks_query = @q.result(distinct: true)

    # 3. Fetch users for the filter dropdown.
    #    This query is now safe because it has no conflicting ORDER BY clause.
    #    It's also good practice to order the users themselves for the dropdown.
    @users = User.where(id: feedbacks_query.select(:user_id)).order(email: :asc)

    # 4. Now, build the final query for displaying the feedbacks by adding
    #    the includes and the desired display order.
    @feedbacks = feedbacks_query.includes(:user).order(created_at: :desc)

    # 5. Apply pagination to the final, sorted results.
    @pagy, @feedbacks = pagy_keyset(@feedbacks, limit: 21)

    # 6. Prepare a new Feedback object for a form, if needed.
    @feedback = Feedback.new
  end

  # GET /feedbacks/1 or /feedbacks/1.json
  def show
  end

  # GET /feedbacks/new
  def new
    if params[:generated_audio_clip_id]
      # Case 1: Feedback for a specific audio clip (from history)
      audio_clip = current_user.generated_audio_clips.find(params[:generated_audio_clip_id])
      @feedback = Feedback.new(
        generated_audio_clip_id: audio_clip.id,
        service: audio_clip.service
      )
    elsif params[:service].present? && Feedback.services.key?(params[:service])
      # Case 2: General feedback for a specific service (from TTS/VC page)
      @feedback = Feedback.new(service: params[:service])
    else
      # Case 3: Completely general feedback (from main index)
      @feedback = Feedback.new
    end
  end

  # GET /feedbacks/1/edit
  def edit
  end

  # POST /feedbacks or /feedbacks.json
  def create
    @feedback = current_user.feedbacks.new(feedback_params)

    respond_to do |format|
      if @feedback.save
        flash.now[:notice] = "Feedback was successfully submitted."
        format.turbo_stream # Renders create.turbo_stream.erb
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
    respond_to do |format|
      @feedback.destroy!
      format.turbo_stream
      flash.now[:notice] = "Feedback was successfully destroyed."
      format.html { redirect_to feedbacks_url, status: :see_other, notice: "Feedback was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feedback
      # For an admin dashboard, finding from all Feedback is appropriate.
      # If users were to manage their own feedback, this would be:
      # @feedback = current_user.feedbacks.find(params[:id])
      @feedback = Feedback.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feedback_params
      # Removed :user_id as it's a security risk and is set from current_user.
      # Note: I'm using the more conventional `require/permit` here. 
      # If `expect` is a custom method in your app, you can swap it back.
      params.require(:feedback).permit(:comment, :rating, :feedback_type, :service, :generated_audio_clip_id)
    end
end