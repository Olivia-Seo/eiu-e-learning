class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         :omniauthable, omniauth_providers: [:google_oauth2]
  rolify       
  has_many :courses  
  has_many :enrollments
  has_many :user_lessons
  has_many :courses, dependent: :nullify
  has_many :enrollments, dependent: :nullify
  has_many :user_lessons, dependent: :nullify
  has_many :comments, dependent: :nullify
   
   def self.from_omniauth(access_token)
      data = access_token.info
      user = User.where(email: data['email']).first
      unless user
         user = User.create(
            email: data['email'],
            password: Devise.friendly_token[0,20],
            confirmed_at: Time.now #autoconfirm user from omniauth
         )
      end
      user
  end
   
  def to_s
    email
  end
  
  def username
    self.email.split(/@/).first
  end

  after_create do
    UserMailer.new_user(self).deliver_later
  end

  
  extend FriendlyId
  friendly_id :email, use: :slugged
  
  after_create :assign_default_role

  def assign_default_role
    if User.count == 1
      self.add_role(:admin) if self.roles.blank?
      self.add_role(:teacher)
      self.add_role(:student)
    else
      self.add_role(:student) if self.roles.blank?
    end
  end

  validate :must_have_a_role, on: :update
  before_update :must_not_remove_last_admin_role
  

  def online?
    updated_at > 2.minutes.ago
  end
  
  def buy_course(course)
    self.enrollments.create(course: course, price: course.price)
  end
  
  def view_lesson(lesson)
    user_lesson = self.user_lessons.where(lesson: lesson)
    if user_lesson.any?
      user_lesson.first.increment!(:impressions)
    else
      self.user_lessons.create(lesson: lesson)
    end
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["comments_count", "confirmation_sent_at", "confirmation_token", "confirmed_at", "courses_count", "created_at", "current_sign_in_at", "current_sign_in_ip", "efresh_token", "email", "encrypted_password", "enrollments_count", "expires", "expires_at", "id", "image", "invitation_accepted_at", "invitation_created_at", "invitation_limit", "invitation_sent_at", "invitation_token", "invitations_count", "invited_by_id", "invited_by_type", "last_sign_in_at", "last_sign_in_ip", "name", "provider", "remember_created_at", "reset_password_sent_at", "reset_password_token", "sign_in_count", "slug", "token", "uid", "unconfirmed_email", "updated_at", "user_lessons_count"]
  end
  
  def has_only_one_admin?
    Role.find_by(name: 'admin').users.count == 1 && has_role?(:admin)
  end
  
  def last_admin?
    has_role?(:admin) && User.with_role(:admin).count == 1
  end

  private
  def must_have_a_role
    unless roles.any? 
      errors.add(:roles, "must have at least one role")
    end
  end
  
  def must_not_remove_last_admin_role
    if has_only_one_admin? && !role_ids.include?(Role.find_by(name: 'admin').id)
      errors.add(:roles, "can't remove admin role from the last admin user")
      throw :abort
    end
  end

end