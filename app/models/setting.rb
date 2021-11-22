class Setting < ApplicationRecord
  belongs_to :user

  include JpPrefecture
  jp_prefecture :prefecture_code
end
