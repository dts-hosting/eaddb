class Destination < ApplicationRecord
  include Descendents

  belongs_to :collection
  has_many :transfers, dependent: :destroy
  has_many :records, through: :transfers
  has_one_attached :config

  validates :name, presence: true, uniqueness: {scope: :type}
  validates :url, presence: true, format: {with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL"}

  encrypts :username
  encrypts :password

  after_create_commit :create_transfers_for_collection_records

  def ok_to_run?
    raise NotImplementedError
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
      .merge(Record.with_ead)
      .where.not(status: "succeeded")
  end

  def reset_transfers_status
    transfers.update_all(status: :pending, message: nil)
  end

  def run(transfer_ids = nil)
    raise NotImplementedError
  end

  private

  def create_transfers_for_collection_records
    collection.records.find_each do |record|
      transfers.create!(record: record)
    end
  end
end
