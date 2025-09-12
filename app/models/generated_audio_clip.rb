class GeneratedAudioClip < ApplicationRecord
  attr_accessor :service_type

  # Associations
  belongs_to :user
  belongs_to :voice, optional: true

  # Validations
  validates :text, presence: true
  validates :voice, presence: true, if: :text_to_speech?

  # The updated enum with the :processing state
  enum :status, {
    pending: 0,
    processing: 1,
    processed: 2,
    failed: 3,
    no_credits: 4
  }

  # THE FIX: Point to a new turbo_stream partial for the broadcast.
  after_create_commit do
    broadcast_render_to [user, "history"],
      partial: "generated_audio_clips/broadcasts/new_clip",
      locals: { audio: self }
  end

  # THE FIX: Point to a new turbo_stream partial for updates.
  after_update_commit do
    broadcast_render_to [user, "history"],
      partial: "generated_audio_clips/broadcasts/update_clip",
      locals: { audio: self }
  end


  private

  # THE FIX: The empty `broadcast_new_clip_to_history` method has been completely removed.
  # Its logic now lives in `app/views/generated_audio_clips/broadcasts/_new_clip.turbo_stream.erb`.

  def text_to_speech?
    service_type == "text_to_speech"
  end
end