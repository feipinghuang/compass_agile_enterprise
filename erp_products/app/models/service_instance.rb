class ServiceInstance < ProductInstance
  attr_protected :created_at, :updated_at

  is_schedulable
end
