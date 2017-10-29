class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true
  validates :password, presence: true, on: :create
  validates_format_of :password,
    with: /(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}/,
    message: 'must include a minimum of eight characters, at least one letter and one number',
    on: %i[create update], allow_nil: true
end
