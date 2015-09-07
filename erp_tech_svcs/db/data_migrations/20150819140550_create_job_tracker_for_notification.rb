class CreateJobTrackerForNotification
  
  def self.up
    JobTracker.create(
        :job_name => 'Notification Job',
        :job_klass => 'ErpTechSvcs::DelayedJobs::NotificationJob'
    )
  end
  
  def self.down
    JobTracker.find_by_job_name('Notification Job').destroy
  end

end
