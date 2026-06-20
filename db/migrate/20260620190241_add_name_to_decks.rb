class AddNameToDecks < ActiveRecord::Migration[7.1]
  def change
    add_column :decks, :name, :string
  end
end
