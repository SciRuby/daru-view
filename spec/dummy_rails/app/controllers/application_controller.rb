class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  layout :resolve_layout

  def nyaplot
    @dv = Daru::Vector.new [:a, :a, :a, :b, :b, :c], type: :category
    # default adapter is nyaplot only
    @bar_graph = Daru::View::Plot.new(@dv, type: :bar, adapter: :nyaplot)

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

    # 3d column chart
    opts = {
        title: {
          text: 'Column 3d demo'
      },

      tooltip: {
          headerFormat: '<b>{series.name}</b><br />',
          pointFormat: 'x = {point.x}, y = {point.y}'
      },
      chart: {
        :defaultSeriesType=>"column" , :margin=> 75,
        options3d: {
            enabled: true,
            alpha: 15,
            beta: 15,
            depth: 50,
            viewDistance: 25}
        },
      plotOptions: {
        :column=>{
            :allowPointSelect=>true,
            :cursor=>"pointer" ,
            :dataLabels=>{
              :enabled=>true,
              :color=>"black",
              :style=>{
                :font=>"13px Trebuchet MS, Verdana, sans-serif"
              }
            },
            depth: 25

          }
        },
      legend: {
        :layout=> 'vertical',
        :style=> {
          :left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'}
        },
      adapter: :highcharts
    }

    series_dt = [{
      :type=> 'column',
      :name=> 'Browser share',
      :data=> [29.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1, 95.6, 54.4]
    }]
    @col_3d = Daru::View::Plot.new(series_dt[0][:data], opts)
    @col_3d.chart.series_data = series_dt


    # html table generated from the daru dataframe and vector
    @df_col = Daru::DataFrame.new({b: [11,12,13,14,15], a: [1,2,3,4,5],
      c: [11,22,33,44,55]},
      order: [:a, :b, :c],
      index: [:one, :two, :three, :four, :five])
    html_code = "<table id='table_id1'>" + @df_col.to_html_thead + @df_col.to_html_tbody + "</table>"
    opts = {
      data: {
              table: 'table_id1'
          },
          chart: {
              type: 'column'
          },
          title: {
              text: 'Data extracted from a HTML table in the page'
          },
          yAxis: {
              allowDecimals: false,
              title: {
                  text: 'Units'
              }
          },
          tooltip: {
              formatter: "function () {
                  return '<b>' + this.series.name + '</b><br/>' +
                      this.point.y + ' ' + this.point.name.toLowerCase();
              }".js_code
          },
          adapter: :highcharts
      }
    col_from_table = Daru::View::Plot.new([],options=opts)
    # col_from_table.chart.options = opts
    @out_col_from_table = html_code + col_from_table.div

  end

  def googlecharts
    # line chart
    opts = {
      title: 'Atmosphere Temperature by Altitude',
      subtitle: 'According to the Standard Atmosphere Model',
      vAxis: {
          title: 'Altitude'
      },
      hAxis:{
          title: 'Temperature',
      },
      adapter: :googlecharts
    }

    data = Daru::DataFrame.rows([[0, 15], [10, -50], [20, -56.5], [30, -46.5], [40, -22.1], [50, -2.5], [60, -27.7], [70, -55.7], [80, -76.5]])
    @line_basic = Daru::View::Plot.new(data, opts)

    # 3d column chart
    opts = {
      type: :column,
      title: 'Column 3d demo',
      adapter: :googlecharts,
      is3D: true,
      height: 700,
      width: 800
    }

    year = Daru::Vector.new([2005, 2006, 2007, 2008, 2009], name: 'Year')
    score = Daru::Vector.new([3.6, 4.1, 3.8, 3.9, 4.6], name: 'Score')
    data = Daru::DataFrame.new(year: year, score: score)
    @col_3d = Daru::View::Plot.new(data, opts)

    year = Daru::Vector.new([2004, 2005, 2006, 2007], name: 'Year')
    sales = Daru::Vector.new([1000, 1170, 660, 1030], name: 'Sales')
    exp = Daru::Vector.new([400, 460, 1120, 540], name: 'Expense')
    data = Daru::DataFrame.new({Year: year, Sales: sales, Expense: exp}, order: [:Year, :Sales, :Expense])
    opts = {type: :column, is3D: true, width: 400, height: 240, title: 'Company Performance', adapter: :googlecharts}
    @col_year_sales_exp = Daru::View::Plot.new(data, opts)

    country_population = [
        ['China', 'China: 1,363,800,000'],
        ['India', 'India: 1,242,620,000'],
        ['US', 'US: 317,842,000'],
        ['Indonesia', 'Indonesia: 247,424,598'],
        ['Brazil', 'Brazil: 201,032,714'],
        ['Pakistan', 'Pakistan: 186,134,000'],
        ['Nigeria', 'Nigeria: 173,615,000'],
        ['Bangladesh', 'Bangladesh: 152,518,015'],
        ['Russia', 'Russia: 146,019,512'],
        ['Japan', 'Japan: 127,120,000']
      ]
    df_cp = Daru::DataFrame.rows(country_population)
    df_cp.vectors = Daru::Index.new(['Country', 'Population'])
    @cp_table = Daru::View::Table.new(df_cp, pageSize: 5, adapter: :googlecharts)
    @map = Daru::View::Plot.new(
    @cp_table.table, type: :map, adapter: :googlecharts, height: 500, width: 800)
  end

  def datatables
    # need to give name, otherwise generated thead html code will not work.
    # Because no name means no thead  in vector.
    dv = Daru::Vector.new [:a, :a, :a, :b, :b, :c], name: 'series1'
    # default adapter is nyaplot only
    @dt_dv = Daru::View::Table.new(dv, pageLength: 3, adapter: :datatables)
    @dt_dv_html = @dt_dv.div

    df1 = Daru::DataFrame.new({b: [11,12,13,14,15], a: [1,2,3,4,5],
      c: [11,22,33,44,55]},
      order: [:a, :b, :c],
      index: [:one, :two, :three, :four, :five])
    @dt_df1 = Daru::View::Table.new(df1, pageLength: 3, adapter: :datatables)
    @dt_df1_html = @dt_df1.div

    df2 = Daru::DataFrame.new({
      a: [1, 3, 5, 7, 5, 0],
      b: [1, 5, 2, 5, 1, 0],
      c: [1, 6, 7, 2, 6, 0]
      }, index: 'a'..'f')
    @dt_df2 = Daru::View::Table.new(df2, pageLength: 3, adapter: :datatables)
    @dt_df2_html = @dt_df2.div
    # user can change the table options using following code :
    #
    # table_opts = {
    #   class: "display",
    #   cellspacing: "0",
    #   width: "50%",
    #   table_html: 'new table thead and tbody html code'
    # }
    # options = {
    #     table_options: table_opts
    # }
    #
    # @dt_df2.table.to_html(id='id1', options)

    dv_arr = [:a, :a, :a, :b, :b, :c]
    @dt_dv_arr = Daru::View::Table.new(dv_arr, pageLength: 3, adapter: :datatables)
    @dt_dv_arr_html = @dt_dv_arr.div

    df1_arr = [
      [11,12,13,14,15],
      [1,2,3,4,5],
      [11,22,33,44,55]
    ]
    @dt_df1_arr = Daru::View::Table.new(df1_arr, pageLength: 3, adapter: :datatables)
    @dt_df1_arr_html = @dt_df1_arr.div

    df2_arr = [
      [1, 3, 5, 7, 5, 0],
      [1, 5, 2, 5, 1, 0],
      [1, 6, 7, 2, 6, 0]
    ]
    @dt_df2_arr = Daru::View::Table.new(df2_arr, pageLength: 3, adapter: :datatables)
    @dt_df2_arr_html = @dt_df2_arr.div

  end


   private
    def resolve_layout
     case action_name
       when "highcharts"
        # setting the library is not needed, if you are parsing the
        # `adapter` option in plot or table.
        Daru::View.plotting_library = :highcharts
        "highcharts_layout"
       when "googlecharts"
        Daru::View.plotting_library = :googlecharts
        "googlecharts_layout"
       when "datatables"
        "datatables_layout"
       else
        Daru::View.plotting_library = :nyaplot
        "application"
       end
    end
end
