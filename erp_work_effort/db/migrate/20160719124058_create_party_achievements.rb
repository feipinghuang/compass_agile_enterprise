class CreatePartyAchievements < ActiveRecord::Migration
  def change

    unless table_exists?(:party_achievements)

      create_table :party_achievements do |t|

        t.references    :party
        t.string        :description
        t.date          :achievement_date
        t.string        :achievement_location_description
        t.string        :sanctioning_organization
        t.string        :achievement_level
        t.text          :custom_fields

        t.timestamps
      end

      add_index :party_achievements, :party_id, :name => "party_achievements_party_id_idx"

    end

  end
end
