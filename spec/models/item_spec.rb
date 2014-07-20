require "rails_helper"

RSpec.describe Item, :type => :model do
  context "without a project name" do
    it "be invalid" do
      expect(subject).to be_invalid
    end
  end

  context "with a subject name" do
    before {
      subject.project_id = 1
      subject.name = "Item name"
      factory = RGeo::Geographic.spherical_factory(srid: 4326)
      subject.point = factory.point(533358.3898999998, 6903801.2723)
    }
    it "be valid" do
      expect(subject).to be_valid
    end
  end
end