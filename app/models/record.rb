class Record < ApplicationRecord
  belongs_to :collection, counter_cache: true
  has_many :transfers, dependent: :destroy
  has_many :destinations, through: :transfers
  has_one_attached :ead_xml

  validates :ead_xml, presence: true
  validates :identifier, presence: true, uniqueness: {scope: :collection_id}
  validates :modification_date, presence: true

  after_commit :update_source_counter, on: [:create, :destroy]
  after_create_commit :create_transfers_for_collection_destinations
  after_update_commit :reset_transfers_status

  scope :for_owner, ->(owner_name) { where(owner: owner_name) }

  private

  def create_transfers_for_collection_destinations
    collection.destinations.find_each do |destination|
      transfers.create!(destination: destination)
    end
  end

  def reset_transfers_status
    transfers.update_all(status: :pending)
  end

  def update_source_counter
    collection.update_source_counter
  end
end
