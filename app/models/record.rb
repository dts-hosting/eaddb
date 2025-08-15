class Record < ApplicationRecord
  belongs_to :collection, counter_cache: true
  has_many :transfers, dependent: :destroy
  has_many :destinations, through: :collection
  has_one_attached :ead_xml

  enum :status, {active: "active", deleted: "deleted", failed: "failed"}, default: :active

  validates :identifier, presence: true, uniqueness: {scope: :collection_id}
  validates :modification_date, presence: true

  after_commit :update_source_counter, on: [:create, :destroy]
  after_create_commit :queue_import
  after_update_commit do
    queue_import if modification_date_changed?
  end

  scope :for_owner, ->(owner) { where(owner: owner) }
  scope :with_ead, -> { where(status: "active").where.not(ead_identifier: nil) }
  scope :without_ead, -> { where(ead_identifier: nil) }

  def ok_to_run?
    return false if failed?

    ead_identifier.present? && ead_xml.attached?
  end

  # queue export of this record to all destinations
  def queue_export
    unless ok_to_run?
      update!(status: "failed", message: "Record is missing EAD identifier and/or XML")
      return
    end

    destinations.each do |destination|
      transfers.create(action: "export", destination: destination)
    end
  end

  # retrieve and process record from source
  def queue_import
    return unless active?

    ProcessRecordJob.perform_later(self)
  end

  # queue deletion of this record from all destinations
  def queue_withdraw
    destinations.each do |destination|
      transfers.create(action: "withdraw", destination: destination)
    end
  end

  def self.untransferables
    joins(collection: :destinations)
      .where(ead_identifier: nil)
      .distinct
  end

  private

  def update_source_counter
    collection.update_source_counter
  end
end
