class AddChargeTypeChargeLinesBizModule

  def self.up
    BusinessModule.where('internal_identifier = ? or parent_module_type = ?', 'charge_lines', 'charge_lines').each do |business_module|

      [business_module.organizer_view, business_module.web_view, business_module.mobile_view].compact.each do |view|
        if view
          unless view.all_detail_view_fields.where(field_name: 'charge_type').first
            meta_data = {
              url: "/api/v1/charge_types",
              root: 'charge_types',
              advanced_search_enabled: false,
              multi_select: false,
              allow_blank: true,
              label_align: 'left',
              service_details: {
                fields:[
                  {
                    name: 'description',
                    header: '',
                    is_value: false,
                    include: true,
                    is_display: true
                  },
                  {
                    name: 'internal_identifier',
                    header: '',
                    is_value: false,
                    include: false,
                    is_display: false
                  },
                  {
                    name: 'id',
                    header: '',
                    is_value: true,
                    include: false,
                    is_display: false
                  }
                ]
              }.to_json
            }

            field_definition = FieldDefinition.new({
                                                     field_name: 'charge_type',
                                                     label: 'Charge Type',
                                                     locked: false,
                                                     is_custom: false,
                                                     field_type: FieldType.iid('service'),
                                                     added_to_view: true
            })
            field_definition.meta_data = meta_data
            field_definition.save!

            view.add_available_field(field_definition, :detail)
            view.add_available_field(field_definition.dup, :list)

            description_list_view_field = view.available_list_view_fields.where('field_name = ?', 'charge_type').first
            description_list_view_field.added_to_view = true
            description_list_view_field.save

            view.field_sets.first.add_field(view.available_detail_view_fields.where('field_name = ?', 'charge_type').first,1) if view.field_sets.first
            view.save
          end # unless
        end # if view
      end # views
      [business_module.organizer_view, business_module.mobile_view].compact.each do |view|
        view.compile
      end
    end # business modules
  end

  def self.down
    #remove data here
  end

end
