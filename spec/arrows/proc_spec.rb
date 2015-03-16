require 'spec_helper'

RSpec.describe Arrows::Proc do
  context 'ID' do
    subject { Arrows::ID }
    specify { should be_a Proc }
  end
  context 'memoize' do
    let(:plus_random) { -> (x) { x + rand(9999999999) } }
    let(:twelve) { Arrows.lift 4 }
    let(:twenty_two) { (twelve >> plus_random).memoize }
    subject { twenty_two.call }
    specify { should eq twenty_two.call }
  end

  context 'polarize' do
    let(:numbers) { Arrows.lift [-2,-1,0,1,2,3] }
    let(:heaviside) { Arrows.polarize { |x| x > 0 } }
    let(:zero) { Arrows.lift { |x| 0 } }
    let(:four) { Arrows.lift { |x| 4 } }
    let(:zero_or_four) { heaviside >> (zero ^ four) }
    let(:actual) { numbers >= zero_or_four }
    context "basics" do
      subject { heaviside.call 2 }
      specify { should be_good }
    end
    context "full-force" do
      subject { actual.call }
      specify { should eq [4,4,4,0,0,0] }
    end
  end

  context 'rescue_from' do
    let(:times2 ) { Arrows.lift -> (x) { x * 2 } }
    let(:plus1) { Arrows.lift -> (x) { x == 4 ? raise(StandardError, "error: #{x}") : (x + 1) } }
    let(:times2_plus1) { times2 >> plus1 }
    let(:caught_proc) { times2_plus1.rescue_from { |e, x| "Oh look, we caught:#{x}" } }
    let(:two) { Arrows.lift 2 }
    let(:five) { two >> caught_proc }
    let(:three) { Arrows.lift(1) >> caught_proc }
    subject { five.call }
    specify { should eq "Oh look, we caught:2" }
    context 'regular usage' do
      subject { three.call }
      specify { should eq 3 }
    end
  end

  context '<=> feedback' do
    let(:step) { Arrows.lift -> (arg_acc) { [arg_acc.first - 1, arg_acc.reduce(&:*)] } }
    let(:chose) { Arrows.lift -> (arg_acc) { arg_acc.first < 1 ? Arrows.good(arg_acc.last) : Arrows.evil(arg_acc) } }
    let(:factorial) { step <=> chose }
    context '120' do
      let(:one_twenty) { Arrows.lift(5) >> factorial }
      subject { one_twenty.call }
      specify { should eq 120 }
    end
    context '1' do
      let(:one) { Arrows.lift(1) >> factorial }
      subject { one.call }
      specify { should eq 1 }
    end
    context '0' do
      let(:zero) { Arrows.lift(0) >> factorial }
      subject { zero.call }
      specify { should eq 0 }
    end
  end

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

  context '/ fanout' do
    let(:times2) { Arrows.lift -> (x) { x * 2 } }
    let(:plus3) { Arrows.lift -> (x) { x + 3 } }
    let(:four) { Arrows.lift 4 }
    let(:six_eight) { four >> times2 / plus3 }
    subject { six_eight.call }
    specify { should eq [8, 7] }
  end

  context '% concurrent' do
    let(:times2) { Arrows.lift -> (x) { x * 2 } }
    let(:plus3) { Arrows.lift -> (x) { x + 3 } }
    let(:four) { Arrows.lift [4,6] }
    context 'validity' do
      subject { times2.call 2 }
      specify { should eq 4 }
    end 
    context 'arity' do
      let(:par) { times2 % plus3 }
      subject { par.call [1,2] }
      specify { should eq [2, 5] }
    end
    context 'result' do
      let(:eight_nine) { four >> times2 % plus3 }
      subject { eight_nine.call }
      specify { should eq [8,9] }
    end
  end

  context '^ fork' do
    let(:times2) { Arrows.lift -> (x) { x * 2 } }
    let(:plus3) { Arrows.lift -> (x) { x + 3 } }
    let(:four) { Arrows.lift Arrows.good 4 }
    let(:eight) { Arrows.lift Arrows.evil 8 }
    let(:fork_four) { four >> (times2 ^ plus3) }
    let(:fork_eight) { eight >> (plus3 ^ times2) }
    context 'good' do
      subject { fork_four.call }
      specify { should eq 8 }
    end
    context 'evil' do
      subject { fork_eight.call }
      specify { should eq 16 }
    end
  end

  context '%/ fanout into concurrent' do
    let(:add1) { Arrows.lift -> (x) { x + 1 } }
    let(:add4) { Arrows.lift -> (x) { x + 4 } }
    let(:two) { Arrows.lift 2 }
    let(:result) { two >> add1 / add4 >> add1 % add4 }
    context 'result' do
      subject { result.call }
      specify { should eq [4, 10] }
    end
  end

  context '>=%/ applicative fanout into concurrent' do
    let(:add1) { Arrows.lift -> (x) { x + 1 } }
    let(:add4) { Arrows.lift -> (x) { x + 4 } }
    let(:twos) { Arrows.lift [2,2,2] }
    let(:transform) { add1 / add4 >> add1 % add4 }
    let(:result) { twos >= add1 / add4 >> add1 % add4 }
    context 'result' do
      subject { result.call }
      specify { should eq [[4,10], [4,10], [4,10]] }
    end
    context 'similarity' do
      let(:actual) { twos >= transform }
      subject { result.call }
      specify { should eq actual.call }
    end
  end
end