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

  # Defines which attributes of the Feedback model are searchable.
  def self.ransackable_attributes(auth_object = nil)
    # List only the attributes your filter form actually uses.
    ["comment", "service", "feedback_type", "user_id", "created_at"]
  end

  # Defines which associations (related models) are searchable.
  # In your case, you might want to search by user attributes in the future.
  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
end