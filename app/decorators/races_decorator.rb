class RacesDecorator < Draper::CollectionDecorator
  def to_show_in_overview
    ApplicationHelper::Helper.find_items_to_show_in_overview(ItemTypes::RACES, object)
  end
end
