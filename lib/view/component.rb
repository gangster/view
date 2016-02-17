require 'view/view_helpers'

module View
  class Component
    def initialize(state = {})
      @state = state
    end

    def display
      raise 'Abstract method.  Implement in subclasses'
    end

    protected
    attr_reader :state
  end
end
