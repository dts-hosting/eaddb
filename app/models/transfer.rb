class Transfer < ApplicationRecord
  belongs_to :destination
  belongs_to :record

  enum :status, { pending: 0, succeeded: 1, failed: 2 }, default: :pending

  validates :status, presence: true
end