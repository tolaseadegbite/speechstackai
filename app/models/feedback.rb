class Feedback < ApplicationRecord
  # -- Associations --
  belongs_to :user
  belongs_to :generated_audio_clip, optional: true

  # -- Enums --
  # Note: I've added the other service from your original prompt.
  enum :service, { text_to_speech: 0, voice_conversion: 1 }
  enum :feedback_type, { review: 0, bug_report: 1, feature_request: 2, general: 3, other: 4 }

  # -- Validations (The critical addition) --
  validates :comment, presence: true, length: { minimum: 10 }
  validates :service, presence: true
  validates :feedback_type, presence: true

  # You might want the rating to be required specifically for reviews.
  validates :rating, presence: true, if: :review?
  validates :rating, numericality: { in: 1..5 }, allow_nil: true # Allow rating to be blank unless it's a review.

  # -- Scopes (Helpful for querying data later) --
  scope :bug_reports, -> { where(feedback_type: :bug_report) }
  scope :feature_requests, -> { where(feedback_type: :feature_request) }
  scope :for_service, ->(service_name) { where(service: service_name) }
end