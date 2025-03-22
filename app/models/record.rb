class Record < ApplicationRecord
  belongs_to :collection, counter_cache: true
  has_one_attached :ead_xml

  validates :ead_xml, presence: true
  validates :identifier, presence: true, uniqueness: { scope: :collection_id }
  validates :modification_date, presence: true
end
