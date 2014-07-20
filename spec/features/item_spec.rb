require "rails_helper"

RSpec.describe Item, :type => :feature do
  it "without any arguments" do
    expect(subject).to be_invalid
  end
end