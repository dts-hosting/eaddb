class Destination < ApplicationRecord
  include Descendents

  belongs_to :collection
  has_many :transfers, dependent: :destroy
  has_many :records, through: :collection
  has_one_attached :config

  enum :status, {active: "active", failed: "failed"}, default: :active

  validates :name, presence: true, uniqueness: {scope: :type}

  attr_readonly :type

  encrypts :username
  encrypts :password

  broadcasts_refreshes

  def exporter
    raise NotImplementedError, "#{self} must implement exporter"
  end

  def has_url?
    raise NotImplementedError, "#{self} must implement has_url?"
  end

  def ready?
    raise NotImplementedError, "#{self} must implement ready?"
  end

  def reset
    ResetDestinationJob.perform_later(self)
  end

  def run
    return unless ready?

    SendRecordsJob.perform_later(self)
  end
end
