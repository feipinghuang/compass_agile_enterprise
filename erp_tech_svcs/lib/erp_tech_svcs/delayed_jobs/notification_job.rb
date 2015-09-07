require 'benchmark'
require 'chronic'

module ErpTechSvcs
  module DelayedJobs
    class NotificationJob

      def initialize
        @priority = 1
      end

      def perform
        logger = Logger.new(File.join(Rails.root,"log/#{Rails.env}-notifications_job.log"), "weekly")
        logger.level = Logger::INFO

        time = Benchmark.measure do
          begin
            Notification.where('current_state = ?', 'pending').each do |notification|
              notification.deliver_notification
            end

          rescue Exception => ex
            logger.error("#{Time.now}**************************************************")
            logger.error("Job Error: #{ex.message}")
            logger.error("Trace: #{ex.backtrace.join("\n")}")
            logger.error("*************************************************************")

            # email notification
            ExceptionNotifier.notify_exception(ex) if defined? ExceptionNotifier
          end
        end

        start_time = Chronic.parse(ErpTechSvcs::Config.notification_job_delay)
        Delayed::Job.enqueue(ErpTechSvcs::DelayedJobs::NotificationJob.new, @priority, start_time)

        #update job tracker
        JobTracker.job_ran('Notification Job', self.class.name, ("(%.4fs)" % time.real), start_time)
      end

      def self.schedule_job(schedule_at)
        Delayed::Job.enqueue(ErpTechSvcs::DelayedJobs::NotificationJob.new, @priority, schedule_at)
      end

    end # NotificationJob
  end # DelayedJobs
end # ErpTechSvcs