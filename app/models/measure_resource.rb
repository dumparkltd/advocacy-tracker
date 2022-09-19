class MeasureResource < VersionedRecord
  belongs_to :measure, required: true
  belongs_to :resource, required: true

  accepts_nested_attributes_for :measure
  accepts_nested_attributes_for :resource

  validates :measure_id, presence: true
  validates :resource_id, presence: true, uniqueness: {scope: :measure_id}

  after_commit :set_relationship_updated, on: [:create, :update, :destroy]

  private

  def set_relationship_updated
    if measure && !measure.destroyed?
      measure.update_column(:relationship_updated_at, Time.zone.now)
      measure.update_column(:relationship_updated_by_id, ::PaperTrail.request.whodunnit)
    end
  end
end
