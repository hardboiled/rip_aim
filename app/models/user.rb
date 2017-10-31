class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true, case_sensitive: false
  validates_format_of :username,
    with: /[\w]+{8,32}/,
    message: 'must include a minimum of eight characters'
  validates :password, presence: true, on: :create
  validates_format_of :password,
    with: /(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,64}/,
    message: 'must include a minimum of eight characters, at least one letter and one number',
    on: %i[create update], allow_nil: true
  before_save :downcase_username

  def downcase_username
    username.downcase! if username_changed?
  end
end
