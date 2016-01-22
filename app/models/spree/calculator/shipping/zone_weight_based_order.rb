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

      validate :validate_at_least_one_rate, :validate_rates_uniqueness

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

      def sorted_rates
        spree_weight_based_calculator_rates.order("from_value ASC")
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
        Spree::ZoneWeightBasedCalculatorRate.find_rate(id, value)
      end

      def validate_at_least_one_rate
        errors.add(:rates,  Spree.t('errors.must_have_at_least_one_shipping_rate')) unless rates.size > 0
      end

      def validate_rates_uniqueness
        new_or_existing_rates = rates.reject { |r| r.marked_for_destruction? }
        errors.add(:rates, Spree.t('errors.weight_based_shipping_must_be_unique'))  if new_or_existing_rates.map(&:from_value).uniq.size < new_or_existing_rates.size
      end

    end
  end
end
