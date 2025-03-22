class Destination < ApplicationRecord
  belongs_to :collection
  has_many :transfers
  has_many :records, through: :transfers

  validates :name, presence: true, uniqueness: {scope: :type}
  validates :url, presence: true, format: {with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL"}

  encrypts :username
  encrypts :password

  after_create_commit :create_transfers_for_collection_records

  private

  def create_transfers_for_collection_records
    collection.records.find_each do |record|
      transfers.create!(record: record)
    end
  end
end
