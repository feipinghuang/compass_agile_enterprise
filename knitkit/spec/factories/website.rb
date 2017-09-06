FactoryGirl.define do
  factory :website do |w|
    w.title "Some Title!"
    w.sequence(:internal_identifier) {|n| "website-#{n}"}
  end
end
