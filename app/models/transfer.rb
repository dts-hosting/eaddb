class Transfer < ApplicationRecord
  belongs_to :destination
  belongs_to :record

  enum :status, {pending: 0, succeeded: 1, failed: 2}, default: :pending

  validates :status, presence: true

  def failed!(error_message = nil)
    update!(status: "failed", message: error_message)
  end

  def succeeded!(success_message = nil)
    update!(status: "succeeded", message: success_message)
  end
end
