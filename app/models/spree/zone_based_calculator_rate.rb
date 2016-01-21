module Spree
  class ZoneBasedCalculatorRate < ActiveRecord::Base
    belongs_to :calculator, class_name: 'Spree::Calculator::Shipping::ZoneBasedOrder'

    scope :for_calculator, -> (calculator_id) { where(calculator_id: calculator_id) }
    scope :for_value, -> (value) { where("from_value <= ?", value) }

    validates :first_weight, :additional_weight, :first_rate, :additional_rate, presence: true
    validates :first_weight, :additional_weight, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 99999.999 }, allow_blank: false
    validates :first_rate, :additional_rate, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 999999.99 }, allow_blank: false


    # Find the rate for the specified value
    def self.find_rate(calculator_id, value)
      range = for_calculator(calculator_id).for_value(value).order("from_value DESC").first
      range && range.rate
    end
  end
end
