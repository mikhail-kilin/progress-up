class AddTables < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :phone, :string
    add_column :users, :description, :string
    add_column :users, :avatar, :string

    create_table :articles do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.integer :user_id
      t.timestamps
    end

    create_table :comments do |t|
      t.integer :article_id
      t.text :content, null: false
      t.integer :user_id
      t.timestamps
    end

    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :entity_id
      t.string :entity_type
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :likes do |t|
      t.integer :article_id
      t.integer :user_id
      t.timestamps
    end

    create_table :progress_informations do |t|
      t.integer :article_id
      t.integer :amount
      t.text :content, null: false
      t.timestamps
    end
  end
end
