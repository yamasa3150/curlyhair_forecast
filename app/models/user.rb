class User < ApplicationRecord
  has_one :setting, dependent: :destroy
  validates :line_user_id, presence: true
end
