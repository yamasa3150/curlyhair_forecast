class CreateSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :settings do |t|
      t.time :push_time, null: false
      t.integer :prefecture_code, null: false
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
