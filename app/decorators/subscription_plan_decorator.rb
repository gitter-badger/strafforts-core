class SubscriptionPlanDecorator < Draper::Decorator
  delegate_all

  def amount
    if object.blank? || object.amount.blank?
      0
    else
      object.amount
    end
  end

  def amount_per_month
    if object.blank? || object.amount_per_month.blank?
      0
    else
      object.amount_per_month
    end
  end
end
