class JobTracker < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  def scheduled?
    !tracked_job.nil?
  end
  
  def tracked_job
    delayed_job_tbl = Delayed::Job.arel_table
    Delayed::Job.where(delayed_job_tbl[:handler].matches("%#{self.job_klass}%")).first
  end
  
  def track_job(job_name)
    job_tracker = JobTracker.where('job_name = ?', job_name).first
    job_tracker = JobTracker.new(:job_name => job_name) if job_tracker.nil?
    job_tracker.save
  end
  
  class << self
    def job_ran(job_name, job_klass, run_time=nil, next_run_at=nil)
      job_tracker = JobTracker.where('job_klass = ?', job_klass).first
      job_tracker = JobTracker.new(:job_name => job_name, :job_klass => job_klass) if job_tracker.nil?
      job_tracker.last_run_at = Time.now
      job_tracker.run_time = run_time
      job_tracker.next_run_at = next_run_at
      job_tracker.save
      
      job_tracker
    end
  end
  
end