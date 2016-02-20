# encoding: utf-8
# frozen_string_literal: true
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
      let(:state) { { oh: 'hi' } }
      let!(:component_subclass) do
        Class.new(View::Component) do
          def html
            content_tag(:p, oh)
          end
        end
      end

      it 'renders the component' do
        expect(view.component(component_subclass, state)).to eq '<p>hi</p>'
      end
    end
  end
end
