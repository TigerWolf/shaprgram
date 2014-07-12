class Item < ActiveRecord::Base

  paginates_per 20

  belongs_to :project
  has_many   :photos

  validates :project_id, :name, presence: true

  accepts_nested_attributes_for :photos, reject_if: :all_blank, allow_destroy: true

  def description
    'lalala'
  end

end
