require 'spec_helper.rb'

describe Daru::View::Plot, 'plotting with highcharts' do
  let(:arr) { [1, 2, 3] }
  before { Daru::View.plotting_library = :highcharts }

  context 'line' do
    let(:plot) { instance_double 'LazyHighCharts::HighCharts' }
    before { allow(LazyHighCharts::HighChart).to receive(:new).and_return(plot) }

    it 'plots line ' do

    end


  end

end
