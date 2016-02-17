require 'rails_helper'

describe ApplicationHelper do
  let(:view) do
    Class.new do
      include ApplicationHelper
    end.new
  end

  context '#component' do
    context 'railtie' do
      it 'responds to the #component message' do
        expect(view).to respond_to :component
      end
    end

    context '#component' do
      let(:state) { { test: 'hi' } }
      let!(:component_subclass) do
        Class.new(View::Component) do
          def display
            content_tag(:p, state[:test])
          end
        end
      end

      it 'renders the component' do
        expect(view.component component_subclass, state).to eq '<p>hi</p>'
      end
    end
  end
end
