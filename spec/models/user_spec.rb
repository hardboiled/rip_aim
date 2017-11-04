require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:username) }
  it { should validate_uniqueness_of(:username) }
  it { should allow_value('hihihihi').for(:username) }
  it { should_not allow_value('hihihih').for(:username) }
  it { should_not allow_value('hihihih$').for(:username) }
  it { should_not allow_value('blahbbbb').for(:password) }
  it { should_not allow_value('b888888').for(:password) }
  it { should allow_value('bb888888').for(:password) }

  it 'should only require password on create' do
    user = FactoryGirl.create(:user)
    user = User.find_by_id(user.id)
    expect(user.valid?).to be(true)
  end

  it 'should not allow have case insensitive usernames' do
    user = FactoryGirl.create(:user, username: 'HelloJohn')
    user.save
    expect(user.username).to eq('hellojohn')
  end

  it 'should get usernames that start with hello' do
    FactoryGirl.create(:user, username: 'hellojohn')
    FactoryGirl.create(:user, username: 'hellojane')
    FactoryGirl.create(:user, username: 'byejane8')
    FactoryGirl.create(:user, username: 'byegeorge')
    expect(User.username_starts_with('hello').count).to eq(2)
  end
end
