class LanguageVoice < ApplicationRecord
  belongs_to :language
  belongs_to :voice
end
