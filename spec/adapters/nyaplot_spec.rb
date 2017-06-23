require 'spec_helper.rb'

# some specs from daru specs
describe Daru::View::Plot, 'plotting Vector with nyaplot library' do
  let(:vector) { Daru::Vector.new([11, 22, 33], index: [:a, :b, :c]) }
  let(:plot) { instance_double('Nyaplot::Plot') }

  before do
    Daru::View.plotting_library = :nyaplot
    allow(Nyaplot::Plot).to receive(:new).and_return(plot)
  end

  it 'plots the vector' do
    expect(plot).to receive(:add).with(:box, [11, 22, 33]).ordered

    expect(Daru::View::Plot.new(vector, type: :box).chart).to eq plot
  end

  context 'scatter' do
    it 'is default type' do
      expect(plot).to receive(:add).with(:scatter, instance_of(Array), instance_of(Array)).ordered

      expect(Daru::View::Plot.new(vector).chart).to eq plot
    end

    it 'sets x_axis to 0...size' do
      expect(plot).to receive(:add).with(:scatter, [0, 1, 2], [11, 22, 33]).ordered

      expect(Daru::View::Plot.new(vector, type: :scatter).chart).to eq plot
    end
  end

  [:box, :histogram].each do |type|
    context type.to_s do
      it 'does not set x axis' do
        expect(plot).to receive(:add).with(type, [11, 22, 33]).ordered

        expect(Daru::View::Plot.new(vector, type: type).chart).to eq plot
      end
    end
  end

  [:bar, :line].each do |type| # FIXME: what other types 2D plot could have?..
    context type.to_s do
      it 'sets x axis to index' do
        expect(plot).to receive(:add).with(type, [:a, :b, :c], [11, 22, 33]).ordered

        expect(Daru::View::Plot.new(vector, type: type).chart).to eq plot
      end
    end
  end
end

# category vector
describe Daru::View::Plot, 'plotting Category Vector with nyaplot library' do
  let(:plot) { instance_double('Nyaplot::Plot') }
  let(:dv) do
    Daru::Vector.new ['III']*10 + ['II']*5 + ['I']*5,
      type: :category,
      categories: ['I', 'II', 'III']
  end
  before do
    Daru::View.plotting_library = :nyaplot
    allow(Nyaplot::Plot).to receive(:new).and_return(plot)
  end
  context 'bar' do
    it 'plots bar graph taking a block' do
      expect(plot).to receive(:add).with(:bar, ['I', 'II', 'III'], [5, 5, 10])
      expect(plot).to receive :x_label
      expect(plot).to receive :y_label
      # need to write with tap, below test
      Daru::View::Plot.new(dv, type: :bar).chart.tap do |p|
        p.x_label 'Categories'
        p.y_label 'Frequency'
      end
    end

    it 'plots bar graph without taking a block' do
      expect(plot).to receive(:add).with(:bar, ["I", "II", "III"], [5, 5, 10])
      expect(Daru::View::Plot.new(dv, type: :bar).chart).to eq plot
    end

    it 'plots bar graph with percentage' do
      expect(plot).to receive(:add).with(:bar, ["I", "II", "III"], [25, 25, 50])
      expect(plot).to receive(:yrange).with [0, 100]
      expect(Daru::View::Plot.new(dv, type: :bar, method: :percentage).chart).to eq plot
    end

    it 'plots bar graph with fraction' do
      expect(plot).to receive(:add).with(:bar, ["I", "II", "III"], [0.25, 0.25, 0.50])
      expect(plot).to receive(:yrange).with [0, 1]
      expect(Daru::View::Plot.new(dv, type: :bar, method: :fraction).chart).to eq plot
    end
  end

  context 'other type' do
    it { expect { Daru::View::Plot.new(dv, type: :scatter) }.to raise_error ArgumentError }
  end
end

# testing DataFrame
class Nyaplot::DataFrame
  # Because it does not allow to any equality testing
  def == other
    other.is_a?(Nyaplot::DataFrame) && rows == other.rows
  end
end

describe Daru::View::Plot, 'plotting DataFrame with Nyaplot library' do
  let(:data_frame) {
    Daru::DataFrame.new({
        x:  [1, 2, 3, 4],
        y1: [5, 7, 9, 11],
        y2: [-3, -7, -11, -15],
        cat: [:a, :b, :c, :d]
      },
      index: [:one, :two, :three, :four]
    )
  }
  let(:plot) { instance_double('Nyaplot::Plot') }

  before do
    allow(Nyaplot::Plot).to receive(:new).and_return(plot)
  end

  context 'box' do
    let(:numerics) { data_frame.only_numerics }
    it 'plots numeric vectors' do
      expect(plot).to receive(:add_with_df)
        .with(numerics.to_nyaplotdf, :box, :x, :y1, :y2)
        .ordered

      expect(Daru::View::Plot.new(data_frame, type: :box).chart).to eq plot
    end
  end

  context 'other types' do
    context 'single chart' do
      it 'works with :y provided' do
        expect(plot).to receive(:add_with_df)
          .with(data_frame.to_nyaplotdf, :scatter, :x, :y1)
          .ordered

        expect(Daru::View::Plot.new(
          data_frame,
          type: :scatter, x: :x, y: :y1).chart
        ).to eq plot
      end

      it 'works without :y provided' do
        expect(plot).to receive(:add_with_df)
          .with(data_frame.to_nyaplotdf, :scatter, :x)
          .ordered

        expect(Daru::View::Plot.new(
          data_frame,
          type: :scatter, x: :x).chart
        ).to eq plot
      end
    end

    context 'multiple charts' do
      it 'works with single type provided' do
        expect(plot).to receive(:add_with_df)
          .with(data_frame.to_nyaplotdf, :scatter, :x, :y1)
          .ordered
        expect(plot).to receive(:add_with_df)
          .with(data_frame.to_nyaplotdf, :scatter, :x, :y2)
          .ordered

        expect(
          Daru::View::Plot.new(
            data_frame, type: :scatter, x: [:x, :x], y: [:y1, :y2]).chart
          ).to eq plot
      end

      it 'works with multiple types provided' do
        expect(plot).to receive(:add_with_df)
          .with(data_frame.to_nyaplotdf, :scatter, :x, :y1)
          .ordered
        expect(plot).to receive(:add_with_df)
          .with(data_frame.to_nyaplotdf, :line, :x, :y2)
          .ordered

        expect(
          Daru::View::Plot.new(
            data_frame,
            type: [:scatter, :line], x: [:x, :x], y: [:y1, :y2]).chart
        ).to eq plot
      end

      it 'works with numeric var names' do
        expect(plot).to receive(:add_with_df)
          .with(data_frame.to_nyaplotdf, :scatter, :x, :y1)
          .ordered
        expect(plot).to receive(:add_with_df)
          .with(data_frame.to_nyaplotdf, :line, :x, :y2)
          .ordered

        expect(
          Daru::View::Plot.new(
            data_frame,
            type: [:scatter, :line],
            # FIXME: this didn't work due to default type: :scatter opts
            #type1: :scatter,
            #type2: :line,
            x1: :x,
            x2: :x,
            y1: :y1,
            y2: :y2
          ).chart
        ).to eq plot
      end
    end
  end
end

describe Daru::View::Plot, 'DataFrame category plotting with Nyaplot lib' do
  context 'scatter' do
    let(:df) do
      Daru::DataFrame.new({
        a: [1, 2, 4, -2, 5, 23, 0],
        b: [3, 1, 3, -6, 2, 1, 0],
        c: ['I', 'II', 'I', 'III', 'I', 'III', 'II']
      })
    end
    let(:plot) { instance_double('Nyaplot::Plot') }
    let(:diagram) { instance_double('Nyaplot::Diagram::Scatter') }

    before do
      df.to_category :c
      allow(Nyaplot::Plot).to receive(:new).and_return(plot)
      allow(plot).to receive(:add_with_df).and_return(diagram)
    end

    it 'plots scatter plot categoried by color with a block' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:color).exactly(3).times
      expect(diagram).to receive(:tooltip_contents).exactly(3).times
      expect(plot).to receive :legend
      expect(plot).to receive :xrange
      expect(plot).to receive :yrange
      Daru::View::Plot.new(
        df, type: :scatter, x: :a, y: :b,
        categorized: {by: :c, method: :color}
      ).chart.tap do |p, d|
        p.xrange [-10, 10]
        p.yrange [-10, 10]
      end
    end

    it 'plots scatter plot categoried by color' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:color).exactly(3).times
      expect(diagram).to receive(:tooltip_contents).exactly(3).times
      expect(plot).to receive :legend
      expect(
        Daru::View::Plot.new(
          df,
          type: :scatter, x: :a, y: :b,
          categorized: {by: :c, method: :color}).chart
      ).to eq plot
    end

    it 'plots scatter plot categoried by custom colors' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:color).with :red
      expect(diagram).to receive(:color).with :blue
      expect(diagram).to receive(:color).with :green
      expect(diagram).to receive(:tooltip_contents).exactly(3).times
      expect(plot).to receive :legend
      expect(
        Daru::View::Plot.new(
          df, type: :scatter, x: :a, y: :b,
          categorized: {by: :c, method: :color, color: [:red, :blue, :green]}
          ).chart
        ).to eq plot
    end

    it 'plots scatter plot categoried by shape' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:shape).exactly(3).times
      expect(diagram).to receive(:tooltip_contents).exactly(3).times
      expect(plot).to receive :legend
      expect(Daru::View::Plot.new(
        df, type: :scatter, x: :a, y: :b,
        categorized: {by: :c, method: :shape}).chart
      ).to eq plot
    end

    it 'plots scatter plot categoried by custom shapes' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:shape).with 'circle'
      expect(diagram).to receive(:shape).with 'triangle-up'
      expect(diagram).to receive(:shape).with 'diamond'
      expect(diagram).to receive(:tooltip_contents).exactly(3).times
      expect(plot).to receive :legend
      expect(
        Daru::View::Plot.new(
          df,
          type: :scatter, x: :a, y: :b,
          categorized: {
            by: :c, method: :shape,
            shape: %w(circle triangle-up diamond)}).chart
      ).to eq plot
    end

    it 'plots scatter plot categoried by size' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:size).exactly(3).times
      expect(diagram).to receive(:tooltip_contents).exactly(3).times
      expect(plot).to receive :legend
      expect(Daru::View::Plot.new(
        df, type: :scatter, x: :a, y: :b,
        categorized: {by: :c, method: :size}).chart).to eq plot
    end

    it 'plots scatter plot categoried by cusom sizes' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:size).with 100
      expect(diagram).to receive(:size).with 200
      expect(diagram).to receive(:size).with 300
      expect(diagram).to receive(:tooltip_contents).exactly(3).times
      expect(plot).to receive :legend
      expect(
        Daru::View::Plot.new(
          df,
          type: :scatter,
          x: :a, y: :b,
          categorized: {
            by: :c,
            method: :size,
            size: [100, 200, 300]
            }
          ).chart
        ).to eq plot
    end
  end

  context 'line' do
    let(:df) do
      Daru::DataFrame.new({
        a: [1, 2, 4, -2, 5, 23, 0],
        b: [3, 1, 3, -6, 2, 1, 0],
        c: ['I', 'II', 'I', 'III', 'I', 'III', 'II']
      })
    end
    let(:plot) { instance_double('Nyaplot::Plot') }
    let(:diagram) { instance_double('Nyaplot::Diagram::Scatter') }

    before do
      df.to_category :c
      allow(Nyaplot::Plot).to receive(:new).and_return(plot)
      allow(plot).to receive(:add_with_df).and_return(diagram)
    end

    it 'plots line plot categoried by color with a block' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:color).exactly(3).times
      expect(plot).to receive :legend
      expect(plot).to receive :xrange
      expect(plot).to receive :yrange
      Daru::View::Plot.new(
        df, type: :line, x: :a, y: :b,
        categorized: {by: :c, method: :color}).chart.tap do |p, d|
          p.xrange [-10, 10]
          p.yrange [-10, 10]
      end
    end

    it 'plots line plot categoried by color' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:color).exactly(3).times
      expect(plot).to receive :legend
      expect(
        Daru::View::Plot.new(df,
          type: :line, x: :a, y: :b,
          categorized: {by: :c, method: :color}
        ).chart
      ).to eq plot
    end

    it 'plots line plot categoried by custom colors' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:color).with :red
      expect(diagram).to receive(:color).with :blue
      expect(diagram).to receive(:color).with :green
      expect(plot).to receive :legend
      expect(
        Daru::View::Plot.new(df,
          type: :line, x: :a, y: :b,
          categorized: {by: :c, method: :color, color: [:red, :blue, :green]}
          ).chart
      ).to eq plot
    end

    it 'plots line plot categoried by stroke width' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:stroke_width).exactly(3).times
      expect(plot).to receive :legend
      expect(
        Daru::View::Plot.new(df,
          type: :line, x: :a, y: :b,
          categorized: {by: :c, method: :stroke_width}
        ).chart
      ).to eq plot
    end

    it 'plots line plot categoried by custom stroke widths' do
      expect(plot).to receive :add_with_df
      expect(diagram).to receive(:title).exactly(3).times
      expect(diagram).to receive(:stroke_width).with 100
      expect(diagram).to receive(:stroke_width).with 200
      expect(diagram).to receive(:stroke_width).with 300
      expect(plot).to receive :legend
      expect(
        Daru::View::Plot.new(df,
          type: :line, x: :a, y: :b,
          categorized: {
            by: :c, method: :stroke_width, stroke_width: [100, 200, 300]}
          ).chart
      ).to eq plot
    end
  end

  context "invalid type" do
    let(:df) do
      Daru::DataFrame.new({
        a: [1, 2, 4, -2, 5, 23, 0],
        b: [3, 1, 3, -6, 2, 1, 0],
        c: ['I', 'II', 'I', 'III', 'I', 'III', 'II']
      })
    end
    it { expect { Daru::View::Plot.new(df, type: :box, categorized: {by: :c, method: :color}).chart }.to raise_error ArgumentError }
  end
end
