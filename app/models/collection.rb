class Collection < ApplicationRecord
  has_many :records, dependent: :destroy

  belongs_to :source, counter_cache: true

  validates :name, presence: true, uniqueness: { scope: :source_id }
  validates :identifier, presence: true, format: { with: %r{\A/repositories/\d+\z} }
end
