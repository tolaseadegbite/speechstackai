class GeneratedAudioClip < ApplicationRecord
  belongs_to :user
  has_many :feedbacks, dependent: :destroy

  # Shared logic
  enum :status, { pending: 0, processing: 1, processed: 2, failed: 3, no_credits: 4 }

  # 1. Broadcast Creation
  after_create_commit do
    broadcast_prepend_to [ user, "history" ],
      target: "history_list",
      partial: self.to_partial_path,
      # REMOVE context: :history
      locals: { "#{self.class.name.underscore}": self }
  end

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
end
