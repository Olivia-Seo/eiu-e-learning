class Course < ApplicationRecord
  after_initialize :set_defaults, unless: :persisted?
  
  
  validates :title,  presence: true
  validates :description, length: { minimum: 5 }
  validates :short_description, length: { maximum: 300 }
  belongs_to :user, counter_cache: true
  has_many :lessons, dependent: :destroy
  has_many :enrollments
  has_many :enrollments, dependent: :restrict_with_error
  has_many :user_lessons, through: :lessons
  has_many :course_tags, inverse_of: :course, dependent: :destroy
  has_many :tags, through: :course_tags
  
  validates :title, uniqueness: true, length: { maximum: 70 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  
  scope :latest, -> { limit(3).order(created_at: :desc) }
  scope :top_rated, -> { limit(3).order(average_rating: :desc, created_at: :desc) }
  scope :popular, -> { limit(3).order(enrollments_count: :desc, created_at: :desc) }
  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :approved, -> { where(approved: true) }
  scope :unapproved, -> { where(approved: false) }
  
  has_one_attached :avatar
  validates :avatar, presence: true,
    content_type: ['image/png', 'image/jpg', 'image/jpeg'], 
    size: { less_than: 500.kilobytes , message: 'size should be under 500 kilobytes' }
  
  def to_s
    title
  end
  has_rich_text :description
  extend FriendlyId
  friendly_id :title, use: :slugged

  LANGUAGES = [:"English", :"Vietnamese"]
  def self.languages
    LANGUAGES.map { |language| [language, language] }
  end

  LEVELS = [:"All levels", :"Beginner", :"Intermediate", :"Advanced"]
  def self.levels
    LEVELS.map { |level| [level, level] }
  end
  #
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }
  
  def bought(user)
    self.enrollments.where(user_id: [user.id], course_id: [self.id]).empty?
  end
  
  def progress(user)
    unless self.lessons_count == 0
      user_lessons.where(user: user).count/self.lessons_count.to_f*100
    end
  end
  
  def update_rating
    if enrollments.any? && enrollments.where.not(rating: nil).any?
      update_column :average_rating, (enrollments.average(:rating).round(2).to_f)
    else
      update_column :average_rating, (0)
    end
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["approved", "average_rating", "created_at", "description", "enrollments_count", "id", "language", "lessons_count", "level", "price", "published", "short_description", "slug", "title", "updated_at", "user_id"]
  end
 
  def self.ransackable_associations(auth_object = nil)
    ["activities", "avatar_attachment", "avatar_blob", "course_tags", "enrollments", "lessons", "rich_text_description", "tags", "user", "user_lessons"]
  end
  
  
  def set_defaults
    self.approved = false
  end
end
