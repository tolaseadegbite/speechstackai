json.extract! feedback, :id, :comment, :rating, :feedback_type, :service, :user_id, :generated_audio_clip_id, :created_at, :updated_at
json.url feedback_url(feedback, format: :json)
