class GeneratedAudioClip < ApplicationRecord
  attr_accessor :service_type

  belongs_to :user
  belongs_to :voice, optional: true   
  has_many :feedbacks, dependent: :destroy

  enum :service, {
    text_to_speech: 0,
    voice_conversion: 1
  }

  enum :status, {
    pending: 0,
    processing: 1,
    processed: 2,
    failed: 3,
    no_credits: 4
  }

  validates :text, presence: true, length: { maximum: 5000 }
  
  validates :voice, presence: true, if: :text_to_speech?

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
end