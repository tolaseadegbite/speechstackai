class GenerateAudioClipJob < ApplicationJob
  queue_as :audio_generation

  limits_concurrency to: 1, key: ->(audio_clip) { audio_clip.user_id }, duration: 5.minutes

  rescue_from(StandardError) do |exception|
    audio_clip = arguments.first
    audio_clip&.failed!
    Rails.logger.error "GenerateAudioClipJob failed for audio_clip #{audio_clip&.id}: #{exception.message}"
    # Optional: You could broadcast a failure notice to the user here if you want.
  end

  def perform(audio_clip)
    # ... (user check, body creation, API call) ...
    # This part remains the same.
    user = audio_clip.user

    unless user.credits > 0
      audio_clip.no_credits!
      return
    end

    endpoint = Rails.application.credentials.modal.generate
    body = { text: audio_clip.text, voice: audio_clip.voice }

    response = ModalApiClient.generate(endpoint, body)

    if response.is_a?(Net::HTTPSuccess)
      response_data = JSON.parse(response.body).deep_symbolize_keys
      process_successful_response(audio_clip, user, response_data)
    else
      raise "Modal API failed with status #{response.code}: #{response.body}"
    end
  end

  private

  def process_successful_response(audio_clip, user, data)
    ApplicationRecord.transaction do
      audio_clip.update!(
        s3_key: data[:s3_key],
        service: "yoruba-tts-modal",
        status: :processed
      )
      deduct_credit(user)
    end

    # --- THIS IS THE NEW KEY PART ---
    # After the transaction is successful, broadcast the new item to the user's history list.
    audio_clip.broadcast_prepend_to [user, "history"],
      target: "history-list",
      partial: "speech_synthesis/partials/history_item",
      locals: { audio: audio_clip }
  end

  def deduct_credit(user)
    user.decrement!(:credits)
  end
end