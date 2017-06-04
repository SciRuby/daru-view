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
  end

  def highcharts

  end
end
