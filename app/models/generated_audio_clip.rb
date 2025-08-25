class GeneratedAudioClip < ApplicationRecord
  attr_accessor :service_type

  validates :text, presence: true
  validates :voice, presence: true

  belongs_to :user

  enum :voice, {
    "Abọ́sẹ̀dé": "Abọ́sẹ̀dé",
    "Adéṣínà": "Adéṣínà",
    "Àrẹ̀mú":   "Àrẹ̀mú",
    "Ewe-Male": "Ewe-Male",
    "Hausa-Male": "Hausa-Male",
    "Lingala-Male": "Lingala-Male",
    "Twi-Akuapem": "Twi-Akuapem",
    "Twi-Asante": "Twi-Asante"
  }

  validates :voice, presence: true, inclusion: { in: voices.keys }

  enum :status, {
    pending: 0,
    processed: 1,
    failed: 2,
    no_credits: 3
  }
end
