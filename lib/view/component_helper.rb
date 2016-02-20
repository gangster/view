# encoding: utf-8
# frozen_string_literal: true
module View
  module ComponentHelper
    include ActionView::Context
    include ActionView::Helpers::CaptureHelper
    include ActionView::Helpers::TextHelper
    extend ActiveSupport::Concern

    included do
      def component(component_class, state = {})
        component_class.new(state).display
      end
    end
  end
end
