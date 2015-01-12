require 'spec_helper'

describe 'Functor Laws' do
  let(:id) do
    -> (x) { x }
  end

  let(:f) do
    -> (x) { ->(y) { x } }.(SecureRandom.base64(1000)).extend(Composable)
  end

  let(:g) do
    -> (x) { ->(y) { x } }.(SecureRandom.base64(1000)).extend(Composable)
  end

  # fmap id = id
  describe 'identity' do
    context 'when i have []' do
      it 'should return []' do
        result = Arrows.fmap(Arrows.lift([]), id)
        expect(result.()).to eq([])
      end
    end

    context 'when i have [:x]' do
      it 'should return [:x]' do
        result = Arrows.fmap(Arrows.lift([:x]), id)
        expect(result.()).to eq([:x])
      end
    end
  end

  # fmap (f . g) = fmap f . fmap g
  describe 'composition' do
    context 'when i have []' do
      it do
        lhs = Arrows.fmap(Arrows.lift([]), f * g)
        rhs = Arrows.fmap(Arrows.fmap(Arrows.lift([]), g), f)
        expect(lhs.()).to eq(rhs.())
      end
    end

    context 'when i have [:x]' do
      it do
        lhs = Arrows.fmap(Arrows.lift([:x]), f * g)
        rhs = Arrows.fmap(Arrows.fmap(Arrows.lift([:x]), g), f)
        expect(lhs.()).to eq(rhs.())
      end
    end
  end
end
