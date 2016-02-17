# encoding: utf-8
# frozen_string_literal: true
module View
  describe Component do
    describe '#initialize' do
      let(:state) { { some: 'state' } }

      it 'initializes state instance variable with state' do
        component = Component.new(state)
        expect(component.instance_variable_get(:@state)).to eq state
      end
    end

    describe '#display' do
      let(:error) { 'Abstract method.  Implement in subclasses' }
      it 'raises a not implemented error' do
        expect { Component.new({}).display }.to raise_error error
      end
    end
  end
end
