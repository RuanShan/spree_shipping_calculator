class CreateSpreeZoneBasedCalculatorRates < ActiveRecord::Migration
  def change
    create_table :spree_zone_based_calculator_rates do |t|
      t.belongs_to :calculator
      t.belongs_to :shipping_method_zone
      t.decimal :from_value,        null: false, precision: 8, scale: 3, default: 0.0
      t.decimal :rate,              null: false, precision: 8, scale: 2, default: 0.0

      t.timestamps null: false
    end

    add_index(:spree_zone_based_calculator_rates, :calculator_id)
    add_index(:spree_zone_based_calculator_rates, :from_value)
  end
end
