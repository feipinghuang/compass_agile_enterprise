# create_table :rulesets do |t|
#   t.string :description
#   t.string :internal_identifier
#
#   t.timestamps
#
# end
#
# add_index :rulesets, :internal_identifier

class Ruleset < ActiveRecord::Base
  attr_protected :created_at, :updated_at

  has_many   :ruleset_rules, dependent: :destroy
  has_many   :business_rules, :through => :ruleset_rules, dependent: :destroy

  class << self
    def import(description, internal_identifier, data)
      data = Hash.symbolize_keys(data)

      ActiveRecord::Base.transaction do
        ruleset = Ruleset.create(description: description,
                                 internal_identifier: internal_identifier)

        data[:business_rules].each do |business_rule_data|

          business_rule = ruleset.business_rules.create(description: business_rule_data[:description], internal_identifier: business_rule_data[:internal_identifier])

          business_rule_data[:rule_matching_conditions].each do |rule_matching_condition_data|
            business_rule.rule_matching_conditions.create(rule_matching_condition_data)
          end

          business_rule_data[:rule_actions].each do |rule_action_data|
            business_rule.rule_actions.create(rule_action_data)
          end

        end # data[:business_rules]

        ruleset

      end
    end # import
  end

  def rules
    business_rules
  end

  def execute(ctx)
    rules.each do |rule|
      ctx = rule.rule_eval(ctx)
    end

    ctx
  end

  def generate_rulebook
    puts "Generating rulebook..."
    puts "\n"
    puts "Rulebook name: " + self.description
    puts "\n"

    rules.each do |r|
      puts "Rule Name: " + r.description
      puts "Combination rule: " + r.match_combination_rule
      puts "\n"
      puts "Match criteria"
      puts "\n"

      r.rule_matching_conditions.each do |mc|
        puts "Matching Condition: " + mc.format_expression.to_s
      end

      puts "\n"
      puts "Actions"
      puts "\n"

      r.rule_actions.each do |a|
        puts "Rule Action: " + a.format_expression.to_s
      end

      puts "\n\n"

    end
  end

  def to_data_hash
    to_hash(only: [:id, :description, :internal_identifier, :created_at, :updated_at])
  end

  def to_tree
    data = {
      record_id: self.id,
      text: self.description,
      internal_identifier: self.internal_identifier,
      children: [],
      record_type: 'Ruleset',
      iconCls: 'icon-ruleset'
    }

    self.business_rules.each do |business_rule|
      data[:children].push({text: business_rule.description, leaf: true, children: [], iconCls: 'icon-rule'})
    end

    data
  end

  def export
    data = to_data_hash

    data.delete(:id)

    data[:business_rules] = business_rules.collect(&:export)

    data
  end

end
