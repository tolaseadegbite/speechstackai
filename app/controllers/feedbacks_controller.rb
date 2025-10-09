class FeedbacksController < DashboardController
  before_action :set_feedback, only: %i[ show edit update destroy ]

  # GET /feedbacks or /feedbacks.json
  # Prepares a list of all feedbacks for an admin view and a new object for the form.
  def index
    # Eager load the user to prevent N+1 queries in the view
    @feedbacks = Feedback.includes(:user).order(created_at: :desc)
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