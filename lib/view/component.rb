# encoding: utf-8
# frozen_string_literal: true
require 'view/view_helpers'

module View
  class Component
    def self.presenter(presenter_class)
      self.presenter = presenter_class
    end

    def initialize(state = {})
      @state = state
    end

    def display
      raise 'Abstract method.  Implement in subclasses'
    end

    def present(object)
      self.class.presenter.new(object)
    end

    protected

    attr_reader :state
  end
end
