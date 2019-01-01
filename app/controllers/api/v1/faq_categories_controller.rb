class Api::V1::FaqCategoriesController < ApplicationController
  # GET /faq_categories
  def index
    @faq_categories = FaqCategory.all_cached

    render json: @faq_categories
  end
end
