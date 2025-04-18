class Record < ApplicationRecord
  belongs_to :collection, counter_cache: true
  has_many :transfers, dependent: :destroy
  has_many :destinations, through: :transfers
  has_one_attached :ead_xml

  enum :status, {active: "active", deleted: "deleted", failed: "failed"}, default: :active

  validates :identifier, presence: true, uniqueness: {scope: :collection_id}
  validates :modification_date, presence: true

  after_commit :update_source_counter, on: [:create, :destroy]
  after_create_commit :create_transfers_for_collection_destinations
  after_update_commit :reset_transfers_status

  scope :for_owner, ->(owner) { where(owner: owner) }
  scope :with_ead, -> { where(status: "active").where.not(ead_identifier: nil) }
  scope :without_ead, -> { where(ead_identifier: nil) }

  # transfer this record to all destinations
  def transfer
    return if failed?

    transfers.includes(:destination).find_each do |transfer|
      transfer.destination.run([transfer.id])
    end
  end

  private

  def create_transfers_for_collection_destinations
    return if failed?

    collection.destinations.find_each do |destination|
      transfers.create!(destination: destination)
    end
  end

  def reset_transfers_status
    transfers.update_all(status: :pending, message: nil)
  end

  def update_source_counter
    collection.update_source_counter
  end
end
