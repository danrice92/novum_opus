class JobExperiencesController < ApplicationController
  protect_from_forgery with: :null_session

  def index
    if params[:user_id]
      @job_experiences = @current_user.job_experiences.order("updated_at DESC")
      @title = "My Experiences"
    else
      @job_experiences = JobExperience.order("updated_at DESC")
      @title = JobExperience::INDEX_TITLE
    end
  end

  def new
    @job_experience = authorize JobExperience.new
  end

  def create
    @job_experience = authorize JobExperience.new job_experience_params
    if @job_experience.save
      add_collaborator @job_experience
      flash.notice = "Your experience has been saved."
      redirect_to root_path
    else
      flash.now[:alert] = "There were errors in your submission, please correct them below."
      render :new
    end
  end

  def edit
    @job_experience = authorize JobExperience.find params[:id]
  end

  def update
    @job_experience = authorize JobExperience.find params[:id]
    if @job_experience.update job_experience_params
      add_collaborator @job_experience
      flash.notice = "This experience has been updated."
      redirect_to root_path
    else
      flash.now[:alert] = "There were errors in your submission, please correct them below."
      render :edit
    end
  end

  private

  def job_experience_params
    params.require(:job_experience).permit(
      :position,
      :company,
      :city,
      :state,
      :experience,
      :pay,
      :recommendation,
      :website,
      :creator_id
    )
  end

  def add_collaborator job_experience
    unless job_experience.collaborator_user_ids.include? @current_user.id
      Collaborator.create(user_id: @current_user.id, job_experience_id: job_experience.id)
    end
  end
end
