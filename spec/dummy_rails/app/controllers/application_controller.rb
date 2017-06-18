class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  layout :resolve_layout

  def nyaplot
    dv = Daru::Vector.new [:a, :a, :a, :b, :b, :c], type: :category
    # default adapter is nyaplot only
    @bar_graph = Daru::View::Plot.new(dv, type: :bar, adapter: :nyaplot)

    df = Daru::DataFrame.new({b: [11,12,13,14,15], a: [1,2,3,4,5],
      c: [11,22,33,44,55]},
      order: [:a, :b, :c],
      index: [:one, :two, :three, :four, :five])
    @scatter_graph = Daru::View::Plot.new df, type: :scatter, x: :a, y: :b, adapter: :nyaplot

    df = Daru::DataFrame.new({
      a: [1, 3, 5, 7, 5, 0],
      b: [1, 5, 2, 5, 1, 0],
      c: [1, 6, 7, 2, 6, 0]
      }, index: 'a'..'f')
    @df_line = Daru::View::Plot.new df, type: :line, x: :a, y: :b, adapter: :nyaplot
  end

  def highcharts
    # line chart : inverted axis
    opts = {
      chart:  {
              type: 'spline',
              inverted: true
          },
      title: {
          text: 'Atmosphere Temperature by Altitude'
      },
      subtitle: {
          text: 'According to the Standard Atmosphere Model'
      },
      xAxis: {
          reversed: false,
          title: {
              enabled: true,
              text: 'Altitude'
          },
          labels: {
              formatter: "function () {
                  return this.value + 'km';
              }".js_code
          },
          maxPadding: 0.05,
          showLastLabel: true
      },
      yAxis:{
          title: {
              text: 'Temperature'
          },
          labels: {
              formatter: "function () {
                  return this.value + '°';
              }".js_code
          },
          lineWidth: 2
      },
      legend:{
          enabled: false
      },
      tooltip:{
          headerFormat: '<b>{series.name}</b><br/>',
          pointFormat: '{point.x} km: {point.y}°C'
      },
      plotOptions:{
          spline: {
              marker: {
                  enable: false
              }
          }
      },
      adapter: :highcharts
    }

    data = [[0, 15], [10, -50], [20, -56.5], [30, -46.5], [40, -22.1],
                  [50, -2.5], [60, -27.7], [70, -55.7], [80, -76.5]]
    @line_inv = Daru::View::Plot.new(data, opts)

    # line chart : chart with line-log-axis/
    opts = {
        title: {
          text: 'Logarithmic axis demo'
      },

      xAxis: {
          tickInterval: 1
      },

      yAxis: {
          type: 'logarithmic',
          minorTickInterval: 0.1
      },

      tooltip: {
          headerFormat: '<b>{series.name}</b><br />',
          pointFormat: 'x = {point.x}, y = {point.y}'
      },
      chart: {type: 'line'},
      adapter: :highcharts
    }

    series_dt = [{
        data: [1, 2, 4, 8, 16, 32, 64, 128, 256, 512],
        pointStart: 1
    }]
    @line_log = Daru::View::Plot.new(series_dt[0][:data], opts)
    @line_log.chart.series_data = series_dt
  end

   private
    def resolve_layout
     case action_name
       when "highcharts"
        Daru::View.plotting_library = :highcharts
        "highcharts_layout"
       else
        Daru::View.plotting_library = :nyaplot
        "application"
       end
    end
end
