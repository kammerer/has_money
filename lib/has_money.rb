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
      write_attribute(attr, c.iso_code)
    end
  end
  
  def has_money(attr, options = {})
    define_method "#{attr}_currency" do
      c = read_attribute("#{attr}_currency") || options[:default_currency]
      if c.present?
        Money::Currency.new(c)
      else
        Money.default_currency
      end
    end

    define_method "#{attr}_currency=" do |c|
      c = Money::Currency.new(c.to_s) unless c.is_a? Money::Currency
      write_attribute("#{attr}_currency", c.iso_code)
    end

    define_method attr do
      cents = read_attribute(attr)
      Money.new(cents, send("#{attr}_currency").iso_code) unless cents.nil?
    end

    define_method "#{attr}=" do |value|
      currency = send("#{attr}_currency")

      unless value.is_a? Money
        value = Money.new(value.to_f * currency.subunit_to_unit, currency.iso_code)
      end

      cents = value.exchange_to(currency.iso_code).cents
      write_attribute(attr, cents)
    end
  end

end
