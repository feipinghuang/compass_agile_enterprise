require 'spec_helper'

describe WorkEffort do
  it "can be instantiated" do
    WorkEffort.new.should be_an_instance_of(WorkEffort)
  end

  it "can be saved successfully" do
    WorkEffort.create().should be_persisted
  end

  # The choice to test AuditLog is arbitrary
  it "a model can acts_as_work_effort" do
    AuditLog.class_eval do
      acts_as_work_effort
    end

    al = AuditLog.new
    al.description = 'test audit log'
    al.party_id = 1
    al.audit_log_type_id = 1
    al.save

    al.should be_an_instance_of(AuditLog)
    al.should be_persisted

    # test creation of work effort
    al.work_effort.should be_an_instance_of(WorkEffort)
    al.work_effort.should be_persisted

    # test destruction of work effort
    work_effort_id = al.work_effort.id
    al.destroy
    WorkEffort.where(:id => work_effort_id).should_not exist
  end

  it "can be started and finished" do
    tst = TrackedStatusType.new
    tst.description = 'test'
    tst.internal_identifier = 'test'
    tst.save

    we = WorkEffort.create
    we.should be_persisted

    # test starting work effort
    we.start!('test')
    we.start_at.should_not be nil
    we.end_at.should be nil
    we.status.should eq 'test'
    we.started?.should be true
    we.finished?.should be false

    # test completing work effort
    we.complete!
    we.end_at.should_not be nil
    we.finished?.should be true
  end
end
