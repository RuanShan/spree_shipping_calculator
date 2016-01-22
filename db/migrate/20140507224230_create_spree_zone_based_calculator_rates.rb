class CreateSpreeZoneBasedCalculatorRates < ActiveRecord::Migration
  def change
    create_table :spree_zone_weight_based_calculator_rates do |t|
      t.belongs_to :calculator
      t.belongs_to :zone
      t.decimal :first_weight,        null: false, precision: 8, scale: 3, default: 0.0
      t.decimal :first_rate,          null: false, precision: 8, scale: 2, default: 0.0
      t.decimal :additional_weight,        null: false, precision: 8, scale: 3, default: 0.0
      t.decimal :additional_rate,          null: false, precision: 8, scale: 2, default: 0.0
      t.timestamps null: false
    end

    add_index(:spree_zone_based_calculator_rates, :shipping_method_zone_id)

  end
end
