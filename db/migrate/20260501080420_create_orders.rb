class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.integer :total_cents
      t.datetime :placed_at

      t.timestamps
    end
  end
end
