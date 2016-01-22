require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class ZoneWeightBasedOrder < ShippingCalculator
      has_many :rates,
               -> { order("from_value ASC") },
               class_name: 'Spree::ZoneWeightBasedCalculatorRate',
               foreign_key: :calculator_id,
               dependent: :destroy

      accepts_nested_attributes_for :rates,
                                    allow_destroy: true

      # If weight is not defined for an item, use this instead
      preference :default_item_weight, :decimal, default: 0
      preference :first_weight, default: 0
      preference :first_rate, :decimal, default: 0.0
      preference :additional_weight, :decimal, default: 0
      preference :additional_rate, :decimal, default: 0.0

      #validate :validate_at_least_one_rate, :validate_rates_uniqueness

      def self.description
        Spree.t(:weight_based_shipping_rate_per_order)
      end

      def compute_package(package)
        content_items = package.contents

        return 0 if package.contents.empty?

        total_weight = total_weight(content_items)
        cost = get_rate_by_weight_and_ship_address( total_weight, package.order.ship_address )

        cost.to_f
      end

      #def available?(package)
      #  package.contents.any? && Spree::WeightBasedCalculatorRate.for_calculator(id).size > 0
      #end

      def self.register
        super
      end


      private

      def total_weight(contents)
        weight = 0
        contents.each do |item|
          weight += item.quantity * (item.variant.weight || preferred_default_item_weight)
        end

        weight
      end

      # Get the rate from the database or nil if could not find the rate
      def get_rate_by_weight_and_ship_address(weight, ship_address)        
        calculator_rate = ( Spree::ZoneWeightBasedCalculatorRate.find_calculator_rate(id, weight, ship_address) || preferences )
        
        compute_by_weight( calculator_rate )
       
      end
     
      def compute_by_weight( weight, calculator_rate )
        first_weight, first_rate, additional_weight, additional_rate = calculator_rate[:first_weight],calculator_rate[:first_rate],calculator_rate[:additional_weight],calculator_rate[:additional_rate]
        if weight <= first_weight
          first_rate
        else
          first_rate + (( weight - first_weight) / additional_weight).ceil * additional_rate
        end
      end

      #def validate_at_least_one_rate
      #  errors.add(:rates,  Spree.t('errors.must_have_at_least_one_shipping_rate')) unless rates.size > 0
      #end

      #def validate_rates_uniqueness
      #  new_or_existing_rates = rates.reject { |r| r.marked_for_destruction? }
      #  errors.add(:rates, Spree.t('errors.weight_based_shipping_must_be_unique'))  if new_or_existing_rates.map(&:from_value).uniq.size < new_or_existing_rates.size
      #end

    end
  end
end
