class VoiceConversionClip < GeneratedAudioClip
  validates :original_voice_s3_key, presence: true

  def to_partial_path
    "voice_conversion_clips/voice_conversion_clip"
  end
end
