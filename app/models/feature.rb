class Feature < ApplicationRecord
  has_many :specs, dependent: :destroy
  belongs_to :project
end
