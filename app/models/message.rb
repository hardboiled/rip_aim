class Message < ApplicationRecord
  enum message_type: { text: 1, image_link: 2, video_link: 3 }
  validates :content, :message_type, :sender, :recipient, presence: true
  belongs_to :sender, class_name: 'User', primary_key: 'sender_id'
  belongs_to :recipient, class_name: 'User', primary_key: 'recipient_id'
  validate :recipient_is_not_sender

  def recipient_is_not_sender
    errors.add(:recipient, 'cannot be the same as sender') if recipient == sender
  end
end
