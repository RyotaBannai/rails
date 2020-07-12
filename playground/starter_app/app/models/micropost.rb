class Micropost < ApplicationRecord
    belongs_to :user
    validates :content, length: { minimum: 0, maximum: 140 }, presence: true
    validates :user_id,  presence: true
end
