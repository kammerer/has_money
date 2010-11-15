require "rubygems"
require "test/unit"
require "mocha"
require "active_record"
require "active_support/test_case"
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'has_money'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'has_money', 'validators'))

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

class ModelWithCurrencyField < Model
  has_currency :currency
end

class ModelWithMoneyField < Model
  has_money :price
end

class ModelWithTwoMoneyFields < Model
  has_currency :currency, :for => [:max_price, :min_price]
  has_money :max_price, :with_currency => :currency
  has_money :min_price, :with_currency => :currency
end

class HasMoneyTest < ActiveSupport::TestCase
  test "has_currency - default value for currency attribute" do
    m = ModelWithCurrencyField.new
    assert_equal Money.default_currency, m.currency
  end

  test "has_currency - setting currency attribute" do
    m = ModelWithCurrencyField.new
    m.currency = "PLN"
    assert_equal Money::Currency.new("PLN"), m.currency
  end

  test "has_money - default value for currency attribute" do
    m = ModelWithMoneyField.new
    assert_equal Money.default_currency, m.price_currency
  end

  test "has_money - setting currency attribute" do
    m = ModelWithMoneyField.new
    m.price_currency = "USD"
    assert_equal Money::Currency.new("USD"), m.price_currency
  end

  test "has_money - default value for money attribute" do
    m = ModelWithMoneyField.new
    assert_equal nil, m.price
  end

  test "has_money - setting float value for money attribute" do
    Money.default_currency = Money::Currency.new("EUR")
    m = ModelWithMoneyField.new
    m.price = 5
    assert_equal Money.new(500, "EUR"), m.price
  end

  test "has_money - setting Money value for money attribute" do
    Money.default_currency = Money::Currency.new("EUR")
    m = ModelWithMoneyField.new
    m.price = Money.new(100, "PLN")
    assert_equal Money.new(25, "EUR"), m.price
  end

  test "has_money - currency exchange" do
    Money.default_currency = Money::Currency.new("EUR")
    m = ModelWithMoneyField.new
    m.price = 1
    m.price_currency = "PLN"
    assert_equal Money.new(400, "PLN"), m.price
  end

  test "has_currency + 2 * has_money - currency exchange" do
    Money.default_currency = Money::Currency.new("EUR")
    m = ModelWithTwoMoneyFields.new
    m.max_price = 5
    m.min_price = 1
    m.currency = "PLN"
    assert_equal Money.new(2000, "PLN"), m.max_price
    assert_equal Money.new(400, "PLN"), m.min_price
  end
end
