module VoicesHelper
  def voice_gradient_style(voice)
    # Provides a fallback to prevent errors if colors are missing
    start_color = voice.gradient_start || "#A5B4FC"
    end_color = voice.gradient_end || "#6366F1"

    "background-image: linear-gradient(135deg, #{start_color}, #{end_color});"
  end
end
