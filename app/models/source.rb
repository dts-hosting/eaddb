class Source < ApplicationRecord
  has_many :collections, dependent: nil
  has_many :records, through: :collections

  validates :name, :type, presence: true
  validates :url, format: {with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL"}
  validates :url, presence: true, uniqueness: {scope: :name, message: "and name combination already exists"}
  validate :url_connectivity

  attr_readonly :type

  encrypts :username
  encrypts :password

  before_destroy :ensure_no_collections

  broadcasts_refreshes

  def broadcast_import_progress(message)
    Turbo::StreamsChannel.broadcast_update_to(
      self,
      target: "source_#{id}_progress_message",
      html: render_progress_message(message)
    )
  end

  def build_validation_url
    raise NotImplementedError
  end

  def client
    raise NotImplementedError
  end

  def duplicate_ead_identifiers
    records
      .where.not(ead_identifier: nil)
      .group(:ead_identifier)
      .having("COUNT(*) > 1")
      .pluck(:ead_identifier)
  end

  def recalculate_total_records_count!
    update_total_records_count
  end

  def run
    raise NotImplementedError
  end

  def self.available_types
    descendants_with_names
      .sort_by { |_, display_name| display_name }
      .map { |klass, name| [name, klass] }
  end

  def self.descendants_with_names
    Rails.application.eager_load! if Rails.env.development?
    descendants = ObjectSpace.each_object(Class).select { |klass| klass < self }

    descendants.map do |klass|
      [klass.to_s, klass.display_name]
    end
  end

  def self.descendants_including_self
    Rails.application.eager_load! if Rails.env.development?
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  def self.display_name
    raise NotImplementedError, "#{self} must implement class method display_name"
  end

  private

  def ensure_no_collections
    if collections.exists?
      errors.add(:base, "Cannot delete source while collections exist.")
      throw(:abort)
    end
  end

  def render_progress_message(message)
    ApplicationController.renderer.render(
      partial: "sources/progress_message",
      locals: {
        message: message,
        timestamp: Time.current.strftime("%H:%M:%S")
      }
    )
  end

  def update_total_records_count
    update_column(:total_records_count, collections.sum(:records_count))
  end

  def url_connectivity
    return if type.blank? || url.blank?

    uri = URI.parse(build_validation_url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      response = http.head(uri)
      errors.add(:url, "returned status #{response.code}") unless response.is_a?(Net::HTTPSuccess)
    end
  rescue => e
    errors.add(:url, "must be a valid resolvable URL: #{e.message}")
  end
end
