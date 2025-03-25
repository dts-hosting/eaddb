class Record < ApplicationRecord
  belongs_to :collection, counter_cache: true
  has_many :transfers, dependent: :destroy
  has_many :destinations, through: :transfers
  has_one_attached :ead_xml

  validates :identifier, presence: true, uniqueness: {scope: :collection_id}
  validates :modification_date, presence: true

  after_commit :update_source_counter, on: [:create, :destroy]
  after_create_commit :create_transfers_for_collection_destinations
  after_update_commit :reset_transfers_status

  scope :for_owner, ->(owner) { where(owner: owner) }
  scope :with_ead, -> {
    joins(ead_xml_join_sql("INNER"))
      # TODO: .where(status: "active")
      .where.not(ead_identifier: nil)
  }
  scope :without_ead, -> {
    joins(ead_xml_join_sql("LEFT"))
      .where("active_storage_attachments.id IS NULL OR records.ead_identifier IS NULL")
  }

  def self.ead_xml_join_sql(join_type)
    <<-SQL.squish
      #{join_type} JOIN active_storage_attachments ON
        active_storage_attachments.record_id = records.id AND
        active_storage_attachments.record_type = 'Record' AND
        active_storage_attachments.name = 'ead_xml'
    SQL
  end

  private

  def create_transfers_for_collection_destinations
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
