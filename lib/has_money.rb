require "money"

# Helper methods for ActiveRecord models which can be used to easily define money and
# currency attributes using +money+ library.
#
#---
# TODO DRY it up
#+++
module HasMoney

  def has_currency(attr, options = {})
    define_method attr do
      c = read_attribute(attr) || options[:default]
      if c.present?
        Money::Currency.new(c)
      else
        Money.default_currency
      end
    end

    define_method "#{attr}=" do |c|
      c = Money::Currency.new(c.to_s) unless c.is_a? Money::Currency

      if options[:for].present?
        money_attrs = Array(options[:for]).flatten
        money_attrs.each do |money_attr|
          m = send("#{money_attr}")
          write_attribute(money_attr, m.exchange_to(c).cents) unless m.nil?
        end
      end

      write_attribute(attr, c.iso_code)
    end
  end
  
  def has_money(attr, options = {})
    currency_attribute = options[:with_currency] || "#{attr}_currency"
    unless options[:with_currency].present?
      define_method currency_attribute do
        c = read_attribute("#{attr}_currency") || options[:default_currency]
        if c.present?
          Money::Currency.new(c)
        else
          Money.default_currency
        end
      end

      define_method "#{currency_attribute}=" do |c|
        c = Money::Currency.new(c.to_s) unless c.is_a? Money::Currency

        m = send("#{attr}")
        write_attribute(attr, m.exchange_to(c).cents) unless m.nil?

        write_attribute("#{attr}_currency", c.iso_code)
      end
    end

    define_method attr do
      cents = read_attribute(attr)
      Money.new(cents, send(currency_attribute).iso_code) unless cents.nil?
    end

    define_method "#{attr}=" do |value|
      currency = send(currency_attribute)

      unless value.is_a? Money
        value = Money.new(value.to_f * currency.subunit_to_unit, currency.iso_code)
      end

      cents = value.exchange_to(currency.iso_code).cents
      write_attribute(attr, cents)
    end
  end

end
