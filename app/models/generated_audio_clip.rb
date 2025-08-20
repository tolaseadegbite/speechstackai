class GeneratedAudioClip < ApplicationRecord
  validates :text, presence: true
  validates :voice, presence: true

  belongs_to :user

  enum :status, {
    pending: 0,
    processed: 1,
    failed: 2,
    no_credits: 3
  }
end
