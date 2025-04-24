class Transfer < ApplicationRecord
  belongs_to :destination
  belongs_to :record

  enum :status, {pending: "pending", succeeded: "succeeded", failed: "failed"}, default: :pending

  after_update_commit -> { broadcast_replace_to self, partial: "records/transfer" }

  def failed!(error_message = nil)
    update!(status: "failed", message: error_message)
  end

  def succeeded!(success_message = nil)
    update!(status: "succeeded", message: success_message)
  end
end
