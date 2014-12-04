require 'spec_helper'

RSpec.describe Arrows::Proc do
  context '>> composition' do
    let(:times2) { -> (x) { x * 2 } }
    let(:plus3) { -> (x) { x + 3 } }
    let(:four) { Arrows.lift 4 }
    let(:fourteen) { four >> plus3 >> times2 }
    subject { fourteen.call }
    specify { should eq 14 }
  end

  context '>= application' do
    let(:times2) { -> (x) { x * 2 } }
    let(:plus3) { -> (x) { x + 3 } }
    let(:twos) { Arrows.lift [2,3,4] }
    let(:tens) { twos >= plus3 >= times2 }
    subject { tens.call }
    specify { should eq [10, 12, 14] }
  end

  context '+ fanout' do
    let(:times2) { Arrows.lift -> (x) { x * 2 } }
    let(:plus3) { Arrows.lift -> (x) { x + 3 } }
    let(:four) { Arrows.lift 4 }
    let(:six_eight) { four >> times2 / plus3 }
    subject { six_eight.call }
    specify { should eq [8, 7] }
  end
end