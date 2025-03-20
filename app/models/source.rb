class Source < ApplicationRecord
  validates :name, presence: true
  validates :url, presence: true
  validate :url_format
  validate :url_connectivity

  encrypts :username
  encrypts :password

  private

  def url_format
    return if url.blank?

    uri = URI.parse(url)
    errors.add(:url, "must be a valid URL") unless uri.kind_of?(URI::HTTP)
  rescue URI::InvalidURIError
    errors.add(:url, "must be a valid URL")
  end

  def url_connectivity
    return if url.blank?

    begin
      uri = URI.parse(url)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request_head(uri.path.presence || '/')
      end
      errors.add(:url, "returned invalid response code: #{response.code}") unless response.is_a?(Net::HTTPSuccess)
    rescue Addressable::URI::InvalidURIError, SocketError, Net::HTTPError, Timeout::Error => e
      errors.add(:url, "is not accessible: #{e.message}")
    end
  end
end
