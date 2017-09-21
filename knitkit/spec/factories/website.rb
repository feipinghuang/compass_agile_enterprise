FactoryGirl.define do
  factory :website do |w|
    w.title "Some Title!"
    w.sequence(:internal_identifier) {|n| "website-#{n}"}
  end

  trait :configure_with_host do
    transient do
      host 'localhost:3000'
      party Party.find_by_description('CompassAE')
    end
    after :create do |website, options|
      FactoryGirl.create(:website_party_role,
                         website: website,
                         party: options.party,
                         role_type: RoleType.iid('dba_org'))

      website.hosts << WebsiteHost.create(:host => options.host)
      website.configurations.first.update_configuration_item(ConfigurationItemType.find_by_internal_identifier('primary_host'), options.host)
      website.save
    end
  end

end
