class GeneratedAudioClip < ApplicationRecord
  belongs_to :user
  has_many :feedbacks, dependent: :destroy

  # Shared logic
  enum :status, { pending: 0, processing: 1, processed: 2, failed: 3, no_credits: 4 }

  # Broadcasts can stay here, acting on 'self'
  after_create_commit :broadcast_creation
end
