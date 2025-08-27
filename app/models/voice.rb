class Voice < ApplicationRecord
  validates :name, :gender, presence: true

  belongs_to :user
  has_many :generated_audio_clips
  has_many :language_voices, dependent: :destroy
  has_many :languages, through: :language_voices

  enum :gender, {
    "Female": "Female",
    "Male": "Male"
  }

  validates :gender, presence: true, inclusion: { in: genders.keys }
end
