class EnrollmentsController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:certificate]
  before_action :set_enrollment, only: [:show, :edit, :update, :destroy, :certificate]
  before_action :set_coruse, only: [:new, :create]

  # GET /enrollments or /enrollments.json
  def index
    #@enrollments = Enrollment.all
    #@pagy, @enrollments = pagy(Enrollment.all)
    @ransack_path = enrollments_path
    
    @q = Enrollment.ransack(params[:q])
    @pagy, @enrollments = pagy(@q.result.includes(:user))
    
    authorize @enrollments
  end
  
  def my_students
    @ransack_path = my_students_enrollments_path
    @q = Enrollment.joins(:course).where(courses: {user: current_user}).ransack(params[:q])
    @pagy, @enrollments = pagy(@q.result.includes(:user))
    render 'index'
  end

  # GET /enrollments/1 or /enrollments/1.json
  def show
  end

  # GET /enrollments/new
  def new
    @enrollment = Enrollment.new
  end

  # GET /enrollments/1/edit
  def edit
    authorize @enrollment
  end

  # POST /enrollments or /enrollments.json
  def create
    @enrollment = current_user.buy_course(@course)
    EnrollmentMailer.student_enrollment(@enrollment).deliver_later
    EnrollmentMailer.teacher_enrollment(@enrollment).deliver_later
    redirect_to course_path(@course), notice: "You are enrolled!"
    #if @course.price > 0
      #flash[:alert] = "You can not access paid courses yet."
      #redirect_to new_course_enrollment_path(@course)
    #else
      #@enrollment = current_user.buy_course(@course)
      #redirect_to course_path(@course), notice: "You are enrolled!"
    #end  
  end

  # PATCH/PUT /enrollments/1 or /enrollments/1.json
  def update
    authorize @enrollment
    respond_to do |format|
      if @enrollment.update(enrollment_params)
        format.html { redirect_to enrollment_url(@enrollment), notice: "Enrollment was successfully updated." }
        format.json { render :show, status: :ok, location: @enrollment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @enrollment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /enrollments/1 or /enrollments/1.json
  def destroy
    authorize @enrollment
    @enrollment.destroy

    respond_to do |format|
      format.html { redirect_to enrollments_url, notice: "Enrollment was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  def certificate
    authorize @enrollment, :certificate?
    respond_to do |format|
      format.pdf do
        render pdf: "#{@enrollment.course.title}, #{@enrollment.user.email}",
               page_size: 'A4',
               template: 'enrollments/certificate.pdf.haml'
      end
    end
  end
  
  def self.ransackable_attributes
    ["comments_count", "confirmation_sent_at", "confirmation_token", "confirmed_at", "courses_count", "created_at", "current_sign_in_at", "current_sign_in_ip", "efresh_token", "email", "encrypted_password", "enrollments_count", "expires", "expires_at", "id", "image", "invitation_accepted_at", "invitation_created_at", "invitation_limit", "invitation_sent_at", "invitation_token", "invitations_count", "invited_by_id", "invited_by_type", "last_sign_in_at", "last_sign_in_ip", "name", "provider", "remember_created_at", "reset_password_sent_at", "reset_password_token", "sign_in_count", "slug", "token", "uid", "unconfirmed_email", "updated_at", "user_lessons_count"]
  end

  private
    def set_coruse
      #binding.pry
      @course = Course.friendly.find(params[:course_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_enrollment
      @enrollment = Enrollment.friendly.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def enrollment_params
      #params.require(:enrollment).permit(:course_id, :user_id, :rating, :review)
      params.require(:enrollment).permit(:rating, :review)
    end
end
