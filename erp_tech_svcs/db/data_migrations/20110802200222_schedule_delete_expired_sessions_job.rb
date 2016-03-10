class ScheduleDeleteExpiredSessionsJob
  
  def self.up
    ErpTechSvcs::DelayedJobs::DeleteExpiredSessionsJob.schedule_job(Time.now)
  end
  
  def self.down
    #remove data here
  end

end
