class Item < ActiveRecord::Base

  belongs_to :project
  has_many   :photos

  validates :project_id, :name, presence: true

  def description
    'lalala'
  end

end
