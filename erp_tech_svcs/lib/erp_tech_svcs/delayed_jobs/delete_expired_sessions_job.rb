require "benchmark"

module ErpTechSvcs
  module DelayedJobs
    # Delayed Job to Reset Daily Assignments to Forecast
    class DeleteExpiredSessionsJob  

      def initialize
        @priority = 1
      end
  
      def perform
        unless Dir.exists?(File.join(Rails.root, 'log/delayed_jobs'))
          Dir.mkdir(File.join(Rails.root, 'log/delayed_jobs'))
        end

        logger = Logger.new(File.join(Rails.root,"log/delayed_jobs/#{Rails.env}-delete_expired_sessions_job.log"), "weekly")
        logger.level = Logger::INFO

        time = Benchmark.measure do
          begin
            ActiveRecord::SessionStore::Session.delete_all ['updated_at < ?', ErpTechSvcs::Config.session_expires_in_hours.hours.ago]
          rescue => ex
            logger.error("#{Time.now}**************************************************")
            logger.error("Job Error: #{ex.message}")
            logger.error("Trace: #{ex.backtrace.join("\n")}")
            logger.error("*************************************************************")

            # email notification
            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier
          end
        end #benchmark
        
        # Run once per day
        start_time = Time.now + 1.day
        
        Delayed::Job.enqueue(DeleteExpiredSessionsJob.new, @priority, start_time)
        
        # Update job tracker
        JobTracker.job_ran('Delete Expired Sessions', self.class.name, ("(%.4fs)" % time.real), start_time)
      end

      def self.schedule_job(schedule_dt)
        Delayed::Job.enqueue(DeleteExpiredSessionsJob.new, @priority, schedule_dt)
      end
  
    end # DeleteExpiredSessionsJob
  end # DelayedJobs
end # ErpTechSvcs
