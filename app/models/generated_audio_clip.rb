class GeneratedAudioClip < ApplicationRecord
  attr_accessor :service_type

  # Associations
  belongs_to :user
  belongs_to :voice, optional: true

  # Validations
  validates :text, presence: true, length: { maximum: 5000 }
  validates :voice, presence: true, if: :text_to_speech?

  # The updated enum with the :processing state
  enum :status, {
    pending: 0,
    processing: 1,
    processed: 2,
    failed: 3,
    no_credits: 4
  }

  def self.ransackable_attributes(auth_object = nil)
    ["text", "created_at"]
  end

  after_create_commit do
    broadcast_render_to [user, "history"],
      partial: "generated_audio_clips/broadcasts/new_clip",
      locals: { audio: self }
  end

  after_update_commit do
    broadcast_render_to [user, "history"],
      partial: "generated_audio_clips/broadcasts/update_clip",
      locals: { audio: self }
  end


  private

  def text_to_speech?
    service_type == "text_to_speech"
  end
end