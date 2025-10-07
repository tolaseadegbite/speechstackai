class GenerateAudioClipJob < ApplicationJob
  queue_as :audio_generation

  limits_concurrency to: 1, key: ->(audio_clip) { audio_clip.user_id }, duration: 5.minutes

  # Update the rescue_from to use a method that triggers the update callback
  rescue_from(StandardError) do |exception|
    audio_clip = arguments.first
    audio_clip&.failed!
    Rails.logger.error "GenerateAudioClipJob failed for audio_clip #{audio_clip&.id}: #{exception.message}"
  end

  def perform(audio_clip)
    audio_clip.processing!

    user = audio_clip.user

    unless user.credits > 0
      audio_clip.no_credits!
      return
    end

    voice_name = audio_clip.voice&.name
    unless voice_name
      raise "GenerateAudioClipJob failed for audio_clip #{audio_clip.id}: No associated Voice record found."
    end

    endpoint = Rails.application.credentials.modal.generate
    body = { text: audio_clip.text, voice: voice_name }
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
        service: :text_to_speech,
        status: :processed
      )
      deduct_credit(user)
    end
  end

  def deduct_credit(user)
    user.decrement!(:credits)
  end
end