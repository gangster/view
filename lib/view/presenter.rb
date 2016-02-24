# encoding: utf-8
# frozen_string_literal: true
module View
  class Presenter < SimpleDelegator
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::AssetUrlHelper
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::DebugHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TranslationHelper
    include ActionView::Helpers::UrlHelper


    protected

    # Q:  Why isn't to_param being handled by method_missing?!  Investigate.
    def to_param
      presented.to_param
    end

    def presented
      __getobj__
    end
  end
end
