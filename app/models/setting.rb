class Setting < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true

  include JpPrefecture
  jp_prefecture :prefecture_code
end
