class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.text :url
      t.string :status

      t.timestamps
    end
  end
end
