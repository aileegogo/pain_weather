class CreateDailyWeathers < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_weathers do |t|
      t.string :location
      t.integer :pressure
      t.integer :humidity
      t.float :temp
      t.integer :pain_level
      t.text :ai_content

      t.timestamps
    end
  end
end
