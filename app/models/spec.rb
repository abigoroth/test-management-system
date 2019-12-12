class Spec < ApplicationRecord
  validates :name , :expected, presence: true
  has_many :results, dependent: :destroy
  belongs_to :feature
end
