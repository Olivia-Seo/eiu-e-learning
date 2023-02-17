class CourseTag < ApplicationRecord
  belongs_to :course
  belongs_to :tag, counter_cache: true
  
  def self.ransackable_attributes(auth_object = nil)
    ["course_id", "created_at", "id", "tag_id", "updated_at"]
  end
  
  def self.ransackable_associations(auth_object = nil)
    ["course", "tag"]
  end
  
end