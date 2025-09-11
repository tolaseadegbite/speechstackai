class GeneratedAudioClip < ApplicationRecord
  attr_accessor :service_type

  # Associations
  belongs_to :user
  belongs_to :voice, optional: true

  # Validations
  validates :text, presence: true
  validates :voice, presence: true, if: :text_to_speech?

  enum :status, {
    pending: 0,
    processing: 1,
    processed: 2,
    failed: 3,
    no_credits: 4
  }

  # THE FIX: Use the simpler broadcast helpers, but call them for each context.
  after_create_commit :broadcast_new_clip_to_history
  after_update_commit :broadcast_updated_clip_to_history

  private

  def broadcast_new_clip_to_history
    is_first_of_the_day = user.generated_audio_clips
                                .where("DATE(created_at) = ?", created_at.to_date)
                                .count == 1

    [:desktop, :mobile].each do |context|
      if is_first_of_the_day
        # If it's the first, prepend the entire date group partial.
        broadcast_prepend_to [user, "history"],
          target: "history_list_#{context}",
          partial: "layouts/shared/history_date_group",
          locals: { date: created_at.to_date, audio_clips: [self], context: context }
      else
        # If not, just prepend the new item into today's existing group.
        broadcast_prepend_to [user, "history"],
          target: "#{context}_history_items_for_#{created_at.to_date.to_s}",
          partial: "layouts/shared/history_item",
          locals: { audio: self, context: context }
      end
    end
  end

  def broadcast_updated_clip_to_history
    # Broadcast a replacement for the DESKTOP view
    broadcast_replace_to [user, "history"],
      target: dom_id(self, :desktop),
      partial: "layouts/shared/history_item",
      locals: { audio: self, context: :desktop }

    # Broadcast a replacement for the MOBILE view
    broadcast_replace_to [user, "history"],
      target: dom_id(self, :mobile),
      partial: "layouts/shared/history_item",
      locals: { audio: self, context: :mobile }
  end

  def text_to_speech?
    service_type == "text_to_speech"
  end
end