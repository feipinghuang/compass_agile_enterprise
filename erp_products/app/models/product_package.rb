class ProductPackage < ProductInstance
  attr_protected :created_at, :updated_at

  def components
    ProdInstanceReln.where('prod_instance_id_to = ?',self.id).collect{|reln| reln.prod_instance_from}
  end

end
