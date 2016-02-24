# encoding: utf-8
# frozen_string_literal: true
require 'view/view_helpers'

module View
  class Component
    include ComponentHelper

    cattr_reader :presenter_class

    def self.presenter(presenter_class)
      @@presenter_class = presenter_class
    end

    def initialize(state = {})

      @state = state.deep_dup
      @state.keys.each do |key|
        self.class.send :define_method, key.to_sym do
          @state[key]
        end
      end
    end

    def display
      capture do
        out = html
        concat out.respond_to?(:flatten) ? safe_join(out) : out
      end
    end

    def html
      raise 'Abstract method.  Implement in subclasses'
    end

    def render(*args)
      options = args.extract_options!
      options.merge!({ locals: state })
      args.push(options)
      Class.new(ActionController::Base).
        renderer.new(request.env).
        render(*args)
    end

    protected

    def present(object)
      self.class.presenter_class.new(object)
    end

    attr_reader :state, :request

  end
end
