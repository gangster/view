module View
  class Presenter
    def initialize(presented)
      @presented = presented
    end

    protected
    # Q:  Why isn't to_param being handled by method_missing?!  Investigate.
    def to_param
      presented.to_param
    end

    def method_missing(method, *args, &block)
      if presented.respond_to? method
        presented.send method, *args, &block
      else
        super
      end
    end
    
    attr_reader :presented
  end
end
