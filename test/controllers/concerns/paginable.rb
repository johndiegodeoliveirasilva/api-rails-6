require 'active_support/concern'

module Paginable
  extend ActiveSupport::Concern
  protected

  def per_page
    (params[:per_page] || 20).to_i
  end
end
