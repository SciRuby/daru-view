class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def nyaplot
    dv = Daru::Vector.new [:a, :a, :a, :b, :b], type: :category
    @bar_graph = Daru::View::Plot.new(dv, type: :bar)

    df = Daru::DataFrame.new({b: [11,12,13,14,15], a: [1,2,3,4,5],
      c: [11,22,33,44,55]},
      order: [:a, :b, :c],
      index: [:one, :two, :three, :four, :five])
    @scatter_graph = Daru::View::Plot.new df, type: :scatter, x: :a, y: :b

    @plot = Nyaplot::Plot.new

    @dv = Daru::Vector.new ['III']*10 + ['II']*5 + ['I']*5, type: :category, categories: ['I', 'II', 'III']
    @plot.x_label("Species"); @plot.y_label("Species2"); @plot.add(:bar, ['Persian', 'Maine Coon', 'American Shorthair'], [10,20,30])
  end

  def highcharts

  end
end
