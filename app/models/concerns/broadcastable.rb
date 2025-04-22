module Broadcastable
  extend ActiveSupport::Concern

  included do
    broadcasts_refreshes
  end

  def broadcast_message(message)
    Turbo::StreamsChannel.broadcast_update_to(
      self,
      target: "#{resolve_base_type}_#{id}_message",
      html: render_message(message)
    )
  end

  private

  def resolve_base_type
    self.class.superclass.name.downcase
  end

  def render_message(message)
    ApplicationController.renderer.render(
      partial: "#{resolve_base_type.pluralize}/message",
      locals: {
        message: message,
        timestamp: Time.current.strftime("%H:%M:%S")
      }
    )
  end
end
