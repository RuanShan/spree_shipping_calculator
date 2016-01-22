module Spree
  class ZoneWeightBasedCalculatorRate < ActiveRecord::Base
    belongs_to :calculator, class_name: 'Spree::Calculator::Shipping::ZoneWeightBasedOrder'
    belongs_to :zone, class_name: 'Spree::Zone'

    scope :for_calculator, -> (calculator_id) { where(calculator_id: calculator_id) }


    validates :first_weight, :additional_weight, :first_rate, :additional_rate, presence: true
    validates :first_weight, :additional_weight, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 99999.999 }, allow_blank: false
    validates :first_rate, :additional_rate, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 999999.99 }, allow_blank: false


    # Find the rate for the specified value
    def self.find_calculator_rate(calculator_id, weight, ship_address)
      for_calculator(calculator_id).detect{|rate| rate.zone.include? ship_address }      
    end

  end
end
