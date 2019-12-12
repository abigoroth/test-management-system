class Project < ApplicationRecord
  has_many :features, dependent: :destroy
end
