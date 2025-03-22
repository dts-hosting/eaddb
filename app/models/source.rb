class Source < ApplicationRecord
  has_many :collections, dependent: :destroy
  has_many :records, through: :collections

  validates :name, presence: true
  validates :url, format: {with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL"}
  validates :url, presence: true, uniqueness: {scope: :name, message: "and name combination already exists"}
  validate :url_connectivity

  encrypts :username
  encrypts :password

  def build_validation_url
    "" # default implementation
  end

  def recalculate_total_records_count!
    update_total_records_count
  end

  def run
    raise NotImplementedError
  end

  private

  def update_total_records_count
    update_column(:total_records_count, collections.sum(:records_count))
  end

  def url_connectivity
    return if url.blank?

    uri = URI.parse(build_validation_url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      response = http.head(uri)
      errors.add(:url, "returned status #{response.code}") unless response.is_a?(Net::HTTPSuccess)
    end
  rescue SocketError, Timeout::Error => e
    errors.add(:url, "connection timed out: #{e.message}")
  rescue => e
    errors.add(:url, "must be a valid resolvable URL: #{e.message}")
  end
end
