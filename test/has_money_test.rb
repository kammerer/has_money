require "rubygems"
require "test/unit"
require "active_record"
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/has_money'))

Money.add_rate("PLN", "EUR", 0.25)
Money.add_rate("EUR", "PLN", 4.0)

class Model
  def write_attribute(attr, value)
    instance_variable_set "@#{attr}", value
  end

  def read_attribute(attr)
    instance_variable_get "@#{attr}"
  end
end

Model.extend(HasMoney)

class ModelWithCurrency < Model
  has_currency :currency
end

class ModelWithMoney < Model
  has_money :price
end

class HasMoneyTest < Test::Unit::TestCase
  def test_has_currency_default_value
    m = ModelWithCurrency.new
    assert_equal Money.default_currency, m.currency
  end

  def test_has_currency
    m = ModelWithCurrency.new
    m.currency = "PLN"
    assert_equal Money::Currency.new("PLN"), m.currency
  end

  def test_has_money_default_price_currency_value
    m = ModelWithMoney.new
    assert_equal Money.default_currency, m.price_currency
  end

  def test_has_money_price_currency_value
    m = ModelWithMoney.new
    m.price_currency = "USD"
    assert_equal Money::Currency.new("USD"), m.price_currency
  end

  def test_has_money_default_price_value
    m = ModelWithMoney.new
    assert_equal nil, m.price
  end

  def test_has_money_float_price_value
    Money.default_currency = Money::Currency.new("EUR")
    m = ModelWithMoney.new
    m.price = 5
    assert_equal Money.new(500, "EUR"), m.price
  end

  def test_has_money_price_value
    Money.default_currency = Money::Currency.new("EUR")
    m = ModelWithMoney.new
    m.price = Money.new(100, "PLN")
    assert_equal Money.new(25, "EUR"), m.price
  end
end
