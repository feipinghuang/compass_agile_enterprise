class CreateEducationHistory < ActiveRecord::Migration
  def change

    unless table_exists?(:education_histories)

      create_table :education_histories do |t|

        t.string      :description
        t.references  :party
        t.string      :school_name
        t.date        :attended_from_date
        t.date        :attended_thru_date
        t.string      :curriculum_description
        t.string      :gpa
        t.text        :custom_fields

        t.timestamps
      end

      add_index :education_histories, :party_id, :name => "education_history_party_id_idx"

    end

  end
end
