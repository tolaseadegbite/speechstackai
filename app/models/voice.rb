class Voice < ApplicationRecord
  validates :name, :gender, presence: true

  before_create :set_random_gradient

  belongs_to :user
  has_many :generated_audio_clips
  has_many :language_voices, dependent: :destroy
  has_many :languages, through: :language_voices

  enum :gender, {
    "Female": "Female",
    "Male": "Male"
  }

  validates :gender, presence: true, inclusion: { in: genders.keys }

  private

  def set_random_gradient
    self.gradient_start ||= generate_random_color
    self.gradient_end ||= generate_random_color
  end

  def generate_random_color
    # Formats a random number as a 6-digit hex string
    "#%06x" % (rand * 0xffffff)
  end
end
