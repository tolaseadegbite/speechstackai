class GeneratedAudioClip < ApplicationRecord
  belongs_to :user
  has_many :feedbacks, dependent: :destroy

  # Shared logic
  enum :status, { pending: 0, processing: 1, processed: 2, failed: 3, no_credits: 4 }

  # 1. Broadcast Creation
  after_create_commit :broadcast_creation

  # 2. Broadcast Update
  after_update_commit do
    # CHANGE: Remove the specific :history argument.
    # Use standard dom_id(self) which produces "text_to_speech_clip_1"
    target_dom_id = ActionView::RecordIdentifier.dom_id(self)

    broadcast_replace_to [ user, "history" ],
      target: target_dom_id,
      partial: self.to_partial_path,
      # REMOVE context: :history
      locals: { "#{self.class.name.underscore}": self }
  end

  private

  def broadcast_creation
    # 1. Calculate the IDs
    today = created_at.to_date
    date_group_id = "date-group-#{today}"
    content_id = "#{date_group_id}_content"

    # 2. Check if this is the FIRST clip of the day for this user
    # We count records created today. If count is 1, it's the first one (self).
    is_first_of_day = user.generated_audio_clips.where(created_at: today.all_day).count == 1

    if is_first_of_day
      # SCENARIO A: It's a new day (or first ever clip).
      # Prepend the WHOLE GROUP (Header + Clip) to the main list.
      broadcast_prepend_to [ user, "history" ],
        target: "history_list",
        partial: "generated_audio_clips/date_group",
        locals: { date: today, clips: [ self ] }
    else
      # SCENARIO B: The day group already exists.
      # Prepend JUST THE CLIP inside the content container (below the header).
      broadcast_prepend_to [ user, "history" ],
        target: content_id,
        partial: self.to_partial_path,
        locals: { "#{self.class.name.underscore}": self }
    end
  end
end
