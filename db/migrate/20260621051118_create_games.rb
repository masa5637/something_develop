class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.references :user, null: false, foreign_key: true
      t.string :difficulty
      t.string :status
      t.jsonb :state

      t.timestamps
    end
  end
end
