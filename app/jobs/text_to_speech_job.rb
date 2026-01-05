class TextToSpeechJob < ApplicationJob
  queue_as :audio_generation

  # Concurrency limit based on User ID
  limits_concurrency to: 1, key: ->(clip) { clip.user_id }, duration: 15.minutes

  rescue_from(StandardError) do |exception|
    clip = arguments.first
    clip&.failed!
    Rails.logger.error "[TextToSpeechJob] Failed ID: #{clip&.id} - #{exception.message}"
  end

  def perform(text_to_speech_clip)
    return unless text_to_speech_clip

    # 1. Update status
    text_to_speech_clip.processing!

    # 2. Validation
    voice_name = text_to_speech_clip.voice&.name
    raise "Voice missing" unless voice_name

    # 3. Call API
    client = ModalApiClient.new
    response_data = client.generate(
      text: text_to_speech_clip.text,
      voice_name: voice_name
    )

    # 4. Success Update
    # The 'after_update_commit' in the parent model will automatically
    # refresh the user's dashboard now.
    text_to_speech_clip.update!(
      s3_key: response_data[:s3_key],
      status: :processed
    )
  end
end
