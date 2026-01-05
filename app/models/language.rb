class Language < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sentitive: false }
  belongs_to :user

  has_many :language_voices, dependent: :destroy
  has_many :voices, through: :language_voices
end
