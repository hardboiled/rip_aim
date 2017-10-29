require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:username) }
  it { should_not allow_value('blahbbbb').for(:password) }
  it { should_not allow_value('b888888').for(:password) }
  it { should allow_value('bb888888').for(:password) }
end