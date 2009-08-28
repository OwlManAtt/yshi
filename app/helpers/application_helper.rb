# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def number_to_isk(amount)
    number_with_delimiter(amount.round(2)).to_s << ' isk'
  end
end
