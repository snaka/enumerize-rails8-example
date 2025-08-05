class User < ApplicationRecord
  extend Enumerize

  # Role (using Symbol array - should work fine)
  enumerize :role, in: [:admin, :manager, :employee, :intern], default: :employee, predicates: true

  # Status (using Hash with numeric values - this might cause issues with bulk operations)
  enumerize :status, in: {
    active: 0,
    inactive: 1,
    suspended: 3
  }, default: :active, scope: true

  # Hobbies (using Symbol array - should work fine)
  serialize :hobbies, coder: JSON, type: Array
  enumerize :hobbies, in: [:reading, :sports, :cooking, :gaming, :music, :travel], multiple: true

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
