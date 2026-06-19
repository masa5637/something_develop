class AddCardTypeFieldsToCards < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :card_type, :string
    add_column :cards, :tier, :integer
    add_column :cards, :effect_target, :string
    add_column :cards, :effect_action, :string
    add_column :cards, :effect_value, :integer
  end
end
