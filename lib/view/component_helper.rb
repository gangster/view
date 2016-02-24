# encoding: utf-8
# frozen_string_literal: true
module View
  module ComponentHelper
    def component(component_class, state = {}, &block)
      state.merge!({ request: request })
      component_class.new(state, &block).display
    end
  end
end
