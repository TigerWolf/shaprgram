actions :create

attribute :app, :name_attribute => true

def initialize(*args)
  super
  @action = :create
end
