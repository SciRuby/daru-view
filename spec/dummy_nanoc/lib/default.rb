require 'daru/view'

def nyaplot_example_line
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
  @df_line = Daru::View::Plot.new(
    df, type: :line, x: :a, y: :b, adapter: :nyaplot
  )
  @df_line.div
end

def nayplot_dependent_js
  Daru::View.dependent_script(:nyaplot)
end

def nyaplot_example_scatter
  df = Daru::DataFrame.new({b: [11,12,13,14,15], a: [1,2,3,4,5],
    c: [11,22,33,44,55]},
    order: [:a, :b, :c],
    index: [:one, :two, :three, :four, :five])
  @scatter_graph = Daru::View::Plot.new df, type: :scatter, x: :a, y: :b, adapter: :nyaplot
  @scatter_graph.div
end

def nyaplot_example_bar
  dv = Daru::Vector.new [:a, :a, :a, :b, :b, :c], type: :category
  # default adapter is nyaplot only
  @bar_graph = Daru::View::Plot.new(dv, type: :bar, adapter: :nyaplot)
  @bar_graph.div
end

def highcharts_dependent_js
  Daru::View.dependent_script(:highcharts)
end

def highcharts_example_line
  opts = {
      chart: {
        defaultSeriesType: 'line',
        height: 600,
        width: 900,
      },
      title: {
        text: 'Solar Employment Growth by Sector, 2010-2016'
        },

      subtitle: {
          text: 'Source: thesolarfoundation.com'
      },

      yAxis: {
          title: {
              text: 'Number of Employees'
          }
      },
      legend: {
          layout: 'vertical',
          align: 'right',
          verticalAlign: 'middle'
      },
      # adapter: :highcharts # set the adapter
    }
  @line_1 = Daru::View::Plot.new([], adapter: :highcharts)
  @line_1.chart.options = opts
  @line_1.chart.series_data = ([{
          name: 'Installation',
          data: [43934, 52503, 57177, 69658, 97031, 119931, 137133, 154175]
      }, {
          name: 'Manufacturing',
          data: [24916, 24064, 29742, 29851, 32490, 30282, 38121, 40434]
      }, {
          name: 'Sales & Distribution',
          data: [11744, 17722, 16005, 19771, 20185, 24377, 32147, 39387]
      }, {
          name: 'Project Development',
          data: [nil, nil, 7988, 12169, 15112, 22452, 34400, 34227]
      }, {
          name: 'Other',
          data: [12908, 5948, 8105, 11248, 8989, 11816, 18274, 18111]
      }])
  [@line_1.chart.series_data, @line_1.div]
end

def highcharts_example_drag
  contents = [
    ["201352",0.7695],
    ["201353",0.7648],
    ["201354",0.7645],
    ["201355",0.7638],
    ["201356",0.7549],
    ["201357",0.7562],
    ["201359",0.7574],
    ["2013510",0.7543],
    ["2013511",0.7510],
    ["2013512",0.7498],
  ]
  opts = {
      chart: {
          zoomType: 'x',
          height: 600,
          width: 900,
      },
      title: {
          text: 'USD to EUR exchange rate over time'
      },
      subtitle: {
          text: "document.ontouchstart === undefined ?
                  'Click and drag in the plot area to zoom in' : 'Pinch the chart to zoom in'".js_code
      },
      # xAxis: {
      #     type: 'datetime' # for date time in javascript. currently not
      # working
      # },
      yAxis: {
          title: {
              text: 'Exchange rate'
          }
      },
      legend: {
          enabled: true
      },
      rangeSelector: {
              selected: 1
      },

      plotOptions: {
          area: {
              fillColor: {
                  linearGradient: {
                      x1: 0,
                      y1: 0,
                      x2: 0,
                      y2: 1
                  },
                  stops: [
                      [0, "Highcharts.getOptions().colors[0]".js_code],
                      [1, "Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')".js_code]
                  ]
              },
              marker: {
                  radius: 2
              },
              lineWidth: 1,
              states: {
                  hover: {
                      lineWidth: 10
                  }
              },
              threshold: nil
          }
      },
    }
  series_dt = ([{
              type: 'area',
              name: 'USD to EUR',
              data: contents
          }])
  line_3 = Daru::View::Plot.new([], adapter: :highcharts)
  line_3.chart.options = opts;
  line_3.chart.series_data = series_dt
  [line_3.chart.series_data, line_3.div]
end

def highcharts_example_dynamic
  # dynamic-update/
  opts = {
      chart: {
          type: 'spline',
          animation: "Highcharts.svg".js_code, # don't animate in old IE
          marginRight: 10,
          events: {
              load: "function () {

                                  // set up the updating of the chart each second
                                  var series = this.series[0];
                                  setInterval(function () {
                                      var x = (new Date()).getTime(), // current time
                                          y = Math.random();
                                      series.addPoint([x, y], true, true);
                                  }, 1000);
                              }".js_code
          },
        height: 600,
        width: 900,
      },
      title: {
          text: 'Live random data'
      },
      xAxis: {
          type: 'datetime',
          tickPixelInterval: 150
      },
      yAxis: {
          title: {
              text: 'Value'
          },
          plotLines: [{
              value: 0,
              width: 1,
              color: '#808080'
          }]
      },
      tooltip: {
          formatter: "function () {
                          return '<b>' + this.series.name + '</b><br/>' +
                              Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) + '<br/>' +
                              Highcharts.numberFormat(this.y, 2);
                      }".js_code
      },
      legend: {
          enabled: false
      },
      exporting: {
          enabled: false
      },
  }

  series_dt = [
    {
          name: 'Random data',
          data: "(function () {
                          // generate an array of random data
                          var data = [],
                              time = (new Date()).getTime(),
                              i;

                          for (i = -19; i <= 0; i += 1) {
                              data.push({
                                  x: time + i * 1000,
                                  y: Math.random()
                              });
                          }
                          return data;
                      }())".js_code
      }
  ]

  dyn_update = Daru::View::Plot.new([], adapter: :highcharts)
  dyn_update.chart.options = opts;
  dyn_update.chart.series_data = series_dt
  [dyn_update.chart.series_data, dyn_update.div]
end

def googlecharts_dependent_js
  Daru::View.dependent_script(:googlecharts)
end

def googlecharts_example_line
  time_popularity = [
        [0, 0],   [1, 10],  [2, 23],  [3, 17],  [4, 18],  [5, 9],
        [6, 11],  [7, 27],  [8, 33],  [9, 40],  [10, 32], [11, 35],
        [12, 30], [13, 40], [14, 42], [15, 47], [16, 44], [17, 48],
        [18, 52], [19, 54], [20, 42], [21, 55], [22, 56], [23, 57],
        [24, 60], [25, 50], [26, 52], [27, 51], [28, 49], [29, 53],
        [30, 55], [31, 60], [32, 61], [33, 59], [34, 62], [35, 65],
        [36, 62], [37, 58], [38, 55], [39, 61], [40, 64], [41, 65],
        [42, 63], [43, 66], [44, 67], [45, 69], [46, 69], [47, 70],
        [48, 72], [49, 68], [50, 66], [51, 65], [52, 67], [53, 70],
        [54, 71], [55, 72], [56, 73], [57, 75], [58, 70], [59, 68],
        [60, 64], [61, 60], [62, 65], [63, 67], [64, 68], [65, 69],
        [66, 70], [67, 72], [68, 75], [69, 80]
      ]
  df_tp = Daru::DataFrame.rows(time_popularity)
  # Time in X axis and Population in Y axis
  df_tp.vectors = Daru::Index.new(['Time', 'Population'])
  table = Daru::View::Table.new(df_tp, pageSize: 10, adapter: :googlecharts)
  line = Daru::View::Plot.new(
    table.table, type: :line, adapter: :googlecharts, height: 500, width: 800)
  [table.div, line.div]
end

def googlecharts_example_geo
  country_population = [
          ['Germany', 200],
          ['United States', 300],
          ['Brazil', 400],
          ['Canada', 500],
          ['France', 600],
          ['RU', 700]
    ]
  df_cp = Daru::DataFrame.rows(country_population)
  df_cp.vectors = Daru::Index.new(['Country', 'Population'])
  table = Daru::View::Table.new(df_cp, pageSize: 5, adapter: :googlecharts, height: 200, width: 200)
  geochart = Daru::View::Plot.new(
    table.table, type: :geo, adapter: :googlecharts, height: 500, width: 800)
  [table.div, geochart.div]
end
