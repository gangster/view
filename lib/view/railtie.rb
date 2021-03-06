# encoding: utf-8
# frozen_string_literal: true
require 'view/component_helper'

module View
  class Railtie < Rails::Railtie
    initializer 'extend ActionView' do

      ActiveSupport.on_load(:action_view) do
        self.class_eval do
          include View::ComponentHelper
        end
      end

      View::Component.send :include, View::ViewHelpers
    end
  end
end
