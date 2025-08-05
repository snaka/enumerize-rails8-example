class User < ApplicationRecord
  extend Enumerize

  # Role
  enumerize :role, in: [:admin, :manager, :employee, :intern], default: :employee, predicates: true

  # Status
  enumerize :status, in: [:active, :inactive, :suspended], default: :active, scope: true

  # Hobbies (multiple selection)
  serialize :hobbies, coder: JSON, type: Array
  enumerize :hobbies, in: [:reading, :sports, :cooking, :gaming, :music, :travel], multiple: true

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
