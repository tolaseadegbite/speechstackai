class TextToSpeechClip < GeneratedAudioClip
  belongs_to :voice

  validates :text, presence: true, length: { maximum: 5000 }
  validates :voice, presence: true

  def to_partial_path
    "text_to_speech_clips/text_to_speech_clip"
  end
end
