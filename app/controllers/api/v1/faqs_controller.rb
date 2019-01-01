class Api::V1::FaqsController < ApplicationController
  before_action :set_faq, only: [:show]

  # GET /faqs
  def index
    @faqs = Faq.all_cached

    render json: @faqs
  end

  # GET /faqs/1
  def show
    render json: @faq
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_faq
    @faq = Faq.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def faq_params
    params.fetch(:faq, {})
  end
end
