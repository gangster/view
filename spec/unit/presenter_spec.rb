require 'rails_helper'

module View
  describe Presenter do
    let(:presenter_class) do
      Class.new(View::Presenter)do
      end
    end

    let(:presented) { double(:presented, name: 'bob') }

    context 'when initializing' do
      it 'sets internal state' do
        presenter = presenter_class.new(presented)
        expect(presenter.send(:presented)).to eq presented
      end
    end

    context 'when delegating' do
      let!(:presenter) { presenter_class.new(presented) }

      context 'when method exists on presented object' do
        it 'delegates to the presented object' do
          expect(presented).to receive :name
          presenter.name
        end
      end

      context 'when method does not exist on presented object' do
        let(:presented) { OpenStruct.new(name: 'bob') }

        it 'raises a NoMethodError' do
          expect { presenter.age }.to raise_error NoMethodError
        end
      end
    end
  end
end
