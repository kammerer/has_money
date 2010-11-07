require File.expand_path(File.join(__FILE__, "..", "lib", "has_money"))

ActiveRecord::Base.extend(HasMoney)
