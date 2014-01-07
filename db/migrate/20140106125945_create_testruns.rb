class CreateTestruns < ActiveRecord::Migration
  def change
    create_table :testruns do |t|
      t.string :status
      t.integer :passed
      t.integer :failed
      t.integer :total

      t.timestamps
    end
  end
end
