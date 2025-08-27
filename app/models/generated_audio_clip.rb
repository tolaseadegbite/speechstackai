class GeneratedAudioClip < ApplicationRecord
  attr_accessor :service_type

  # Associations
  belongs_to :user

  belongs_to :voice, optional: true

  # Validations
  validates :text, presence: true

  # This validation will ONLY run if the text_to_speech? method returns true.
  validates :voice, presence: true, if: :text_to_speech?

  enum :status, {
    pending: 0,
    processed: 1,
    failed: 2,
    no_credits: 3
  }

  private

  def text_to_speech?
    service_type == "text_to_speech"
  end
end
