class Collection < ApplicationRecord
  belongs_to :source, counter_cache: true
  has_many :destinations, dependent: :destroy
  has_many :records, dependent: :destroy

  validates :name, presence: true, uniqueness: {scope: :source_id}
  validates :identifier, presence: true, uniqueness: {scope: :source_id}, format: {with: %r{\A/repositories/\d+\z}}

  def has_owner?(name)
    owner == name
  end

  def requires_owner?
    require_owner_in_record
  end

  def update_source_counter
    source.recalculate_total_records_count!
  end
end
