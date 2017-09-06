FactoryGirl.define do
  factory :website_section do |w|
    w.title "some_section_title"
    w.sequence(:internal_identifier) {|n| "website-#{n}"}
  end
end
