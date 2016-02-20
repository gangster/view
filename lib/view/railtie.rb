# encoding: utf-8
# frozen_string_literal: true
require 'view/component_helper'

module View
  class Railtie < Rails::Railtie
    initializer 'extend ApplicationHelper' do
      config.eager_load_namespaces << View
      ApplicationHelper.send :include, View::ComponentHelper
      View::Component.send :include, View::ViewHelpers
      View::Component.send :include, View::ComponentHelper
    end
  end
end
