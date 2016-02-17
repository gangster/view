# encoding: utf-8
# frozen_string_literal: true
module View
  module ComponentHelper
    include ActionView::Helpers::CaptureHelper
    include ActionView::Context
    include ActionView::Helpers::TextHelper
    extend ActiveSupport::Concern

    included do
      def component(component_class, state = {})
        component = component_class.new(state)
        capture do
          concat component.display
        end
      end
    end
  end
end
