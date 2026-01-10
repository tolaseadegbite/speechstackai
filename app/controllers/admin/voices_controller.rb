module Admin
  class VoicesController < BaseController
    before_action :set_voice, only: [ :show, :edit, :update, :destroy ]

    def index
      @voices = Voice.includes(:languages).order(created_at: :desc)
    end

    def show
    end

    def new
      @voice = Voice.new
    end

    def create
      @voice = current_user.voices.new(voice_params)
      if @voice.save
        redirect_to admin_voices_path, notice: "Voice added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @voice.update(voice_params)
        redirect_to admin_voices_path, notice: "Voice updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @voice.destroy
      redirect_to admin_voices_path, notice: "Voice deleted."
    end

    private

    def set_voice
      @voice = Voice.find(params[:id])
    end

    def voice_params
      params.require(:voice).permit(:name, :gender, :description, :s3_key, :gradient_start, :gradient_end, :is_active, language_ids: [])
    end
  end
end
