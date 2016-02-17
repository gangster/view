# encoding: utf-8
# frozen_string_literal: true
require 'view/component_helper'

module View
  class Railtie < Rails::Railtie
    initializer 'extend ApplicationHelper' do
      ApplicationHelper.send :include, View::ComponentHelper
      View::Component.send :include, View::ViewHelpers
    end
  end
end
