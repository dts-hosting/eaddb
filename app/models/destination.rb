class Destination < ApplicationRecord
  include Broadcastable
  include Descendents

  belongs_to :collection
  has_many :transfers, dependent: :destroy
  has_many :records, through: :transfers
  has_one_attached :config

  enum :status, {active: "active", failed: "failed"}, default: :active

  validates :name, presence: true, uniqueness: {scope: :type}
  validates :url, presence: true, format: {with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL"}

  attr_readonly :type

  encrypts :username
  encrypts :password

  after_create_commit :create_transfers_for_collection_records

  def exporter
    raise NotImplementedError, "#{self} must implement exporter"
  end

  def is_local?
    false
  end

  def ok_to_run?
    raise NotImplementedError, "#{self} must implement ok_to_run?"
  end

  def pending_deletes
    transfers
      .joins(:record)
      .where(record: {status: "deleted"})
      .where.not(record: {ead_identifier: nil})
      .where.not(status: "succeeded")
  end

  def pending_transfers
    transfers
      .joins(:record)
      .where(record: {status: "active"})
      .where.not(record: {ead_identifier: nil})
      .where.not(status: "succeeded")
  end

  def reset
    ResetDestinationJob.perform_later(self)
    transfers.update_all(status: "pending", message: nil)
  end

  def run(transfer_ids = nil)
    return unless ok_to_run?

    SendRecordsJob.perform_later(self, transfer_ids)
  end

  private

  def create_transfers_for_collection_records
    transferables.find_each do |record|
      transfers.create!(record: record)
    end
  end

  def transferables
    collection.records.where.not(status: "failed")
      .where.not(ead_identifier: nil)
  end
end
