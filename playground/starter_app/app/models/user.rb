class User < ApplicationRecord
    has_many :microposts, dependent: :destroy
    validates :name, presence: true
    validates :email, presence: true
    has_one_attached :avatar
end
