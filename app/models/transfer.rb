class Transfer < ApplicationRecord
  belongs_to :destination
  belongs_to :record

  enum :action, {export: "export", withdraw: "withdraw"}, default: :export
  enum :status, {pending: "pending", succeeded: "succeeded", failed: "failed"}, default: :pending

  after_create_commit -> { TransferJob.perform_later(self) }
  after_update_commit -> { broadcast_replace_to self, partial: "shared/transfer" }

  scope :latest_active, -> { recent.not_pending }
  scope :not_pending, -> { where.not(status: "pending") }
  scope :pending, -> { where(status: "pending") }
  scope :recent, -> { where("updated_at > ?", 1.day.ago) }

  def failed!(error_message = nil)
    update!(status: "failed", message: error_message)
  end

  def succeeded!(success_message = nil)
    update!(status: "succeeded", message: success_message)
  end
end
