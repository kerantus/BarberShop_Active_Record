class CreateBarbers < ActiveRecord::Migration[5.1]
  def change

    create_table :barbers do |t|
      t.text :name

      t.timestamps
    end
  end
end
