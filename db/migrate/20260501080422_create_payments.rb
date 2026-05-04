class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :provider
      t.string :status
      t.integer :amount_cents
      t.string :transaction_id
      t.datetime :paid_at

      t.timestamps
    end
  end
end
