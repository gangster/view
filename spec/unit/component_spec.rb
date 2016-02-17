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
      it 'raises a not implemented error' do
        expect { Component.new({}).display }.to raise_error 'Abstract method.  Implement in subclasses'
      end
    end
  end
end
