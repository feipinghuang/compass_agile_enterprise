module ErpBaseErpSvcs
  module Extensions
    module ActiveRecord
      module HasTrackedStatus
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def has_tracked_status
            extend HasTrackedStatus::SingletonMethods
            include HasTrackedStatus::InstanceMethods

            has_many :status_applications, :as => :status_application_record, :dependent => :destroy

            scope :with_status, lambda { |status_type_iids|
                                joins(:status_applications => :tracked_status_type).
                                    where("status_applications.thru_date IS NULL AND tracked_status_types.internal_identifier IN (?)",
                                          status_type_iids)
                              }

            # scope record by its current status application
            # status_type_iids can either be an Array of status to scope by or a Hash with the parent status
            # as the key and the children statues to scope by as the value
            scope :with_current_status, lambda { |status_type_iids=[]|
                                        model_table = self.arel_table
                                        status_applications_tbl = StatusApplication.arel_table

                                        #determine status_application_record_type
                                        status_application_record_type = (self.superclass == ::ActiveRecord::Base) ? self.name.to_s : self.superclass.to_s

                                        current_status_select = status_applications_tbl.project(status_applications_tbl[:id].maximum)
                                                                    .where(model_table[:id].eq(status_applications_tbl[:status_application_record_id])
                                                                               .and(status_applications_tbl[:status_application_record_type].eq(status_application_record_type)))

                                        statement = joins(:status_applications => :tracked_status_type).where(status_applications_tbl[:id].in(current_status_select))

                                        if status_type_iids
                                          status_ids = []

                                          if status_type_iids.is_a?(Hash)
                                            parent_status = TrackedStatusType.iid(status_type_iids.keys.first)
                                            status_ids = parent_status.children.where(:internal_identifier => status_type_iids.values.first).pluck(:id)

                                          elsif status_type_iids.is_a?(Array)
                                            unless status_type_iids.empty?
                                              status_ids = order_statuses.children.where(:internal_identifier => status_type_iids).pluck(:id)
                                            end
                                          end

                                          unless status_ids.empty?
                                            statement = statement.where(TrackedStatusType.arel_table[:id].in status_ids)
                                          end
                                        end

                                        statement
                                      }

            # scope record by its current status application and exclude records with the passed statuses
            # status_type_iids can either be an Array of status to scope by or a Hash with the parent status
            # as the key and the children statues to scope by as the value
            scope :without_current_status, lambda { |status_type_iids=[]|
                                           model_table = self.arel_table
                                           status_applications_tbl = StatusApplication.arel_table

                                           #determine status_application_record_type
                                           status_application_record_type = (self.superclass == ::ActiveRecord::Base) ? self.name.to_s : self.superclass.to_s

                                           current_status_select = status_applications_tbl.project(status_applications_tbl[:id].maximum)
                                                                       .where(model_table[:id].eq(status_applications_tbl[:status_application_record_id])
                                                                                  .and(status_applications_tbl[:status_application_record_type].eq(status_application_record_type)))

                                           statement = joins(:status_applications => :tracked_status_type).where(status_applications_tbl[:id].in(current_status_select))

                                           if status_type_iids
                                             status_ids = []

                                             if status_type_iids.is_a?(Hash)
                                               parent_status = TrackedStatusType.iid(status_type_iids.keys.first)
                                               status_ids = parent_status.children.where(:internal_identifier => status_type_iids.values.first).pluck(:id)

                                             elsif status_type_iids.is_a?(Array)
                                               unless status_type_iids.empty?
                                                 status_ids = order_statuses.children.where(:internal_identifier => status_type_iids).pluck(:id)
                                               end
                                             end

                                             unless status_ids.empty?
                                               statement = statement.where(TrackedStatusType.arel_table[:id].in status_ids)
                                             end
                                           end

                                           statement
                                         }
          end
        end

        module SingletonMethods
        end

        module InstanceMethods

          # does this status match the current_status?
          def has_status?(tracked_status_iid)
            current_status == tracked_status_iid
          end

          # did it have this status in the past but NOT currently?
          def had_status?(tracked_status_iid)
            return false if has_status?(tracked_status_iid)
            has_had_status?(tracked_status_iid)
          end

          # does it now or has it ever had this status?
          def has_had_status?(tracked_status_iid)
            result = self.status_applications.joins(:tracked_status_types).where("tracked_status_types.internal_identifier = ?", tracked_status_iid)
            result.nil? ? false : true
          end

          #get status for given date
          #checks from_date attribute
          def get_status_for_date_time(datetime)
            status_applications = StatusApplication.arel_table

            arel_query = StatusApplication.where(status_applications[:from_date].gteq(datetime - 1.day).or(status_applications[:from_date].lteq(datetime + 1.day)))

            arel_query.all
          end

          #get status for passed date range from_date and thru_date
          #checks from_date attribute
          def get_statuses_for_date_time_range(from_date, thru_date)
            status_applications = StatusApplication.arel_table

            arel_query = StatusApplication.where(status_applications[:from_date].gteq(from_date - 1.day).or(status_applications[:from_date].lteq(from_date + 1.day)))
            arel_query = arel_query.where(status_applications[:thru_date].gteq(thru_date - 1.day).or(status_applications[:thru_date].lteq(thru_date + 1.day)))

            arel_query.all
          end

          # gets current StatusApplication record
          def current_status_application
            self.status_applications.where("status_applications.thru_date IS NULL").order('id DESC').first
          end

          # get's current status's tracked_status_type
          def current_status_type
            self.current_status_application.tracked_status_type unless self.current_status_application.nil?
          end

          # gets current status's internal_identifier
          def current_status
            self.current_status_type.internal_identifier unless self.current_status_type.nil?
          end

          #set current status of entity.
          #takes a TrackedStatusType internal_identifier and creates a StatusApplication
          #with from_date set to today and tracked_status_type set to passed TrackedStatusType internal_identifier
          #optionally can passed from_date and thru_date to manually set these
          #it will set the thru_date on the current StatusApplication to now
          def current_status=(args)
            options = {}

            if args.is_a?(Array)
              status = args[0]
              options = args[1]
              user_id = args[2]
            else
              status = args
            end

            tracked_status_type = status.is_a?(TrackedStatusType) ? status : TrackedStatusType.find_by_internal_identifier(status.to_s)
            raise "TrackedStatusType does not exist #{status.to_s}" unless tracked_status_type

            # if passed status is current status then do nothing
            unless self.current_status_type && (self.current_status_type.id == tracked_status_type.id)
              #set current StatusApplication thru_date to now
              cta = self.current_status_application
              unless cta.nil?
                cta.thru_date = options[:thru_date].nil? ? Time.now : options[:thru_date]
                cta.save
              end

              status_application = StatusApplication.new
              status_application.tracked_status_type = tracked_status_type
              status_application.from_date = options[:from_date].nil? ? Time.now : options[:from_date]
              status_application.user_id = user_id
              status_application.save

              self.status_applications << status_application
              self.save
            end

          end

          def previous_status
            result = self.status_applications.joins(:tracked_status_type).order("status_applications.id desc").limit(2).all
            if result.count == 2
              result[1].tracked_status_type.internal_identifier
            else
              nil
            end
          end

          # add_status aliases current_status= for legacy support
          def add_status(tracked_status_iid)
            self.current_status = tracked_status_iid
          end

        end

      end #HasTrackedStatus
    end #Rezzcard
  end #ActiveRecord
end #Extensions

ActiveRecord::Base.send :include, ErpBaseErpSvcs::Extensions::ActiveRecord::HasTrackedStatus