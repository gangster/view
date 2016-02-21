# encoding: utf-8
# frozen_string_literal: true
module View
  class Presenter
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::AssetUrlHelper
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::DebugHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TranslationHelper
    include ActionView::Helpers::UrlHelper

    def initialize(presented)
      @presented = presented
    end

    protected

    # Q:  Why isn't to_param being handled by method_missing?!  Investigate.
    def to_param
      presented.to_param
    end

    def method_missing(method, *args, &block)
      if presented.respond_to? method
        presented.send method, *args, &block
      else
        super
      end
    end

    attr_reader :presented
  end
end
