class Transfer < ApplicationRecord
  belongs_to :destination
  belongs_to :record

  enum :status, {pending: "pending", succeeded: "succeeded", failed: "failed"}, default: :pending

  after_update_commit -> { broadcast_replace_to self, partial: "records/transfer" }

  scope :recent, -> { where("updated_at > ?", 1.day.ago) }
  scope :not_pending, -> { where.not(status: "pending") }
  scope :latest_active, -> { recent.not_pending }

  def failed!(error_message = nil)
    update!(status: "failed", message: error_message)
  end

  def succeeded!(success_message = nil)
    update!(status: "succeeded", message: success_message)
  end
end
