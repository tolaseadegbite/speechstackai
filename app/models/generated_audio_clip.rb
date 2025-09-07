class GeneratedAudioClip < ApplicationRecord
  attr_accessor :service_type

  # Associations
  belongs_to :user
  belongs_to :voice, optional: true

  # Validations
  validates :text, presence: true
  validates :voice, presence: true, if: :text_to_speech?

  # The updated enum with the :processing state
  enum :status, {
    pending: 0,
    processing: 1,
    processed: 2,
    failed: 3,
    no_credits: 4
  }

  # This broadcasts the initial "pending" state.
  after_create_commit :broadcast_new_clip_to_history

  # This broadcasts all subsequent status updates (processing, processed, failed).
  after_update_commit do
    broadcast_replace_to [user, "history"],
      partial: "layouts/shared/history_item",
      locals: { audio: self }
  end


  private

  def broadcast_new_clip_to_history
    # Check if this is the first clip of the day for this user.
    is_first_of_the_day = user.generated_audio_clips
                                .where("DATE(created_at) = ?", created_at.to_date)
                                .count == 1

    if is_first_of_the_day
      # If it's the first, prepend the entire date group partial.
      broadcast_prepend_to [user, "history"],
        target: "history-list",
        partial: "layouts/shared/history_date_group",
        locals: { date: created_at.to_date, audio_clips: [self] }
    else
      # If not, just prepend the new item into today's existing group.
      broadcast_prepend_to [user, "history"],
        target: "history_items_for_#{created_at.to_date.to_s}",
        partial: "layouts/shared/history_item",
        locals: { audio: self }
    end
  end

  def text_to_speech?
    service_type == "text_to_speech"
  end
end