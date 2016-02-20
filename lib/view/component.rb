# encoding: utf-8
# frozen_string_literal: true
require 'view/view_helpers'

module View
  class Component

    def self.presenter(presenter_class)
      self.presenter = presenter_class
    end

    def initialize(state = {})
      copy = state.deep_dup
      state.keys.each do |key|
        self.class.send :define_method, key.to_sym do
          copy[key]
        end
      end
    end

    def display
      capture do
        out =  html.respond_to?(:flatten) ? safe_join(html) : html
        concat out
      end
    end

    def html
      raise 'Abstract method.  Implement in subclasses'
    end

    def present(object)
      self.class.presenter.new(object)
    end
  end
end
