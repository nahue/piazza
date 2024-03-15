class User < ApplicationRecord
  # before_validation :strip_extraneous_spaces
  has_secure_password

  validates :name, presence: true
  validates :email,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 8 }

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :app_sessions

  normalizes :name, with: ->(name) { name.strip }
  normalizes :email, with: ->(email) { email.strip.downcase }

  def self.create_app_session(email:, password:)
    user = User.authenticate_by(email:, password:)
    user.app_sessions.create if user.present?
  end

  def authenticate_app_session(app_session_id, token)
    app_sessions.find(app_session_id).authenticate_token(token)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
