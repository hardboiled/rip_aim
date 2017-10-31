class Message < ApplicationRecord
  enum message_type: { text: 1, image_link: 2, video_link: 3 }
  validates :content, :message_type, :sender, :recipient, presence: true
  belongs_to :sender, class_name: 'User', primary_key: 'id'
  belongs_to :recipient, class_name: 'User', primary_key: 'id'
  validate :recipient_is_not_sender

  scope :between_users, lambda { |user1, user2|
    where(sender: user1, recipient: user2)
      .or(where(sender: user2, recipient: user1))
      .order(created_at: :desc)
  }

  def recipient_is_not_sender
    errors.add(:recipient_id, 'cannot be the same as sender') if recipient == sender
  end
end
