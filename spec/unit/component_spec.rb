# encoding: utf-8
# frozen_string_literal: true

require 'rails_helper'

module View
  describe Component do
    let(:request) { Rack::MockRequest.new('/') }
    let(:state) { { some: 'state', request: request } }

    describe '#initialize' do

      it 'initializes state instance variable with state' do
        component = Component.new(state)
        expect(component.some).to eq state[:some]
      end
    end

    describe '#display' do
      let(:error) { 'Abstract method.  Implement in subclasses' }
      it 'raises a not implemented error' do
        expect { Component.new(state).display }.to raise_error error
      end
    end

    describe '#component' do
      it 'responds to #component' do
        expect(Component.new(state)).to respond_to :component
      end
    end
  end
end
