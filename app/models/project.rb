class Project < ActiveRecord::Base

  belongs_to :user
  belongs_to :administrative_boundry
  has_many :items
  has_many :data_imports

  def headers
    %w(name point)
  end

end
