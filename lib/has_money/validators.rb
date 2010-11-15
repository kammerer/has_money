require "money"

module HasMoney
  module Validators
    class BaseValidator
      attr_accessor :instance, :attr, :options

      def initialize(instance, attr, options = {})
        self.instance = instance
        self.attr = attr
        self.options = options
      end
    end

    class CurrencyValidator < BaseValidator
      def validate
        valid_currencies = options[:in] || Money::Currency::TABLE.values.collect { |row| row[:iso_code] }
        instance.errors.add(attr, options[:message] || :invalid_currency) unless valid_currencies.include?(instance.send(attr).iso_code) 
      end
    end

    class MoneyValidator < BaseValidator
      def validate
        money = instance.send(attr)

        # TODO solve problem of validation of non-numeric values. at this moment it is impossible, since money attribute
        # setter does not accept them

        if options[:less_than]
          minimum = (options[:less_than].to_f * money.currency.subunit_to_unit).round(2)
          if money.cents >= minimum
            instance.errors.add(attr, options[:message] || :less_than, :low => Money.new(minimum, money.currency).to_s)
          end
        end

        if options[:less_than_or_equal]
          minimum = (options[:less_than_or_equal].to_f * money.currency.subunit_to_unit).round(2)
          if money.cents > minimum
            instance.errors.add(attr, options[:message] || :less_than_or_equal,  low => Money.new(minimum, money.currency).to_s)
          end
        end

        if options[:greater_than]
          maximum = (options[:greater_than].to_f * money.currency.subunit_to_unit).round(2)
          if money.cents <= maximum
            instance.errors.add(attr, options[:message] || :greater_than, :hight => Money.new(maximum, money.currency).to_s)
          end
        end

        if options[:greater_than_or_equal]
          maximum = (options[:greater_than_or_equal].to_f * money.currency.subunit_to_unit).round(2)
          if money.cents < maximum 
            instance.errors.add(attr, options[:message] || :greater_than_or_equal, :high => Money.new(minimum, money.currency).to_s)
          end
        end

        if options[:between]
          minimum = (options[:between].first.to_f * money.currency.subunit_to_unit).round(2)
          maximum = (options[:between].last.to_f * money.currency.subunit_to_unit).round(2)
          if money.cents < minimum || money.cents > maximum
            instance.errors.add(attr, options[:message] || :between, :low => Money.new(minimum, money.currency).to_s,
                                                                     :high => Money.new(maximum, money.currency).to_s)
          end
        end
      end
    end
  end
end
