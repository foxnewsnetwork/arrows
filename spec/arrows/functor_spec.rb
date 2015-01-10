require 'spec_helper'

describe 'Functor Instance' do
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
    it do
      result = Arrows.fmap(Arrows.lift([:x]), id)
      expect(result.()).to eq([:x])
    end
  end

  # fmap (f . g) = fmap f . fmap g
  describe "composition" do
    it do
      lhs = Arrows.fmap(Arrows.lift([:x]), f * g)
      rhs = Arrows.fmap(Arrows.fmap(Arrows.lift([:x]), g), f)
      expect(lhs.()).to eq(rhs.())
    end
  end
end
