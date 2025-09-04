class VoicesController < DashboardController
  before_action :set_voice, only: %i[ show edit update destroy ]
  before_action :set_languages, only: %i[ new create edit update ]

  # GET /voices or /voices.json
  def index
    @voices = Voice.all
  end

  # GET /voices/1 or /voices/1.json
  def show
  end

  # GET /voices/new
  def new
    @voice = Voice.new
  end

  # GET /voices/1/edit
  def edit
  end

  # POST /voices or /voices.json
  def create
    @voice = current_user.voices.new(voice_params)

    respond_to do |format|
      if @voice.save
        format.html { redirect_to @voice, notice: "Voice was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /voices/1 or /voices/1.json
  def update
    respond_to do |format|
      if @voice.update(voice_params)
        format.html { redirect_to @voice, notice: "Voice was successfully updated." }
        format.json { render :show, status: :ok, location: @voice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @voice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /voices/1 or /voices/1.json
  def destroy
    @voice.destroy!

    respond_to do |format|
      format.html { redirect_to voices_path, status: :see_other, notice: "Voice was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_voice
      @voice = Voice.find(params.expect(:id))
    end

    def set_languages
      @languages = Language.order(:name)
    end

    # Only allow a list of trusted parameters through.
    def voice_params
      params.expect(voice: [ :name, :gender, :description, :s3_key, language_ids: [] ])
    end
end
