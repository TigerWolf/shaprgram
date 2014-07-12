class Item < ActiveRecord::Base

  paginates_per 20

  belongs_to :project
  has_many   :photos

  validates :project_id, :name, presence: true

  accepts_nested_attributes_for :photos, reject_if: :all_blank, allow_destroy: true

  def description
    'lalala'
  end

  scope :near, lambda { |latitude, longitude, distance_in_meters = 100000|
    where(%{
      ST_DWithin(
        point,
        ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
        %d
      )
    } % [latitude, longitude, distance_in_meters])
  }

end
