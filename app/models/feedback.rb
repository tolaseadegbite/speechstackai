class Feedback < ApplicationRecord
  belongs_to :user
  belongs_to :generated_audio_clip, optional: true

  enum :service, { text_to_speech: 0, voice_conversion: 1 }
  enum :feedback_type, { review: 0, bug_report: 1, feature_request: 2, general: 3, other: 4 }

  validates :comment, presence: true, length: { minimum: 10 }
  validates :service, presence: true
  validates :feedback_type, presence: true

  validates :rating, presence: true, if: :review?
  validates :rating, numericality: { in: 1..5 }, allow_nil: true

  scope :bug_reports, -> { where(feedback_type: :bug_report) }
  scope :feature_requests, -> { where(feedback_type: :feature_request) }
  scope :for_service, ->(service_name) { where(service: service_name) }

  def self.ransackable_attributes(auth_object = nil)
    ["comment", "service", "feedback_type", "rating", "user_id", "created_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
end