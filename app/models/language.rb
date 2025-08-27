class Language < ApplicationRecord
  belongs_to :user

  has_many :language_voices, dependent: :destroy
  has_many :voices, through: :language_voices
end
