## 0.1.0 (2017-09-20)

**Features:**

- Generate Plot using [Nyaplot](https://github.com/SciRuby/nyaplot),
[google_visualr](https://github.com/winston/google_visualr/),
[lazy_high_charts](https://github.com/michelson/lazy_high_charts) gem with more features.

- Generate Tables using [Google Charts DataTable](https://developers.google.com/chart/interactive/docs/gallery/table) and [daru-data_tables](https://github.com/Shekharrajak/daru-data_tables) with features like pagination, sorting by column, option to choose number of rows to be displayed.

- Plotting can be done in IRuby notebook as well as any ruby web application
framework.

- Data can be in Daru::DataFrame, Daru::Vector, array of array data or
according to the formate described in [Google Charts tool](https://developers.google.com/chart/interactive/docs/gallery), [Highcharts](https://www.highcharts.com/demo).

- User can use all the features already present in google_visualr,
lazy_high_charts, nayplot by accessing the respective object using
`#chart` and tables using `#table`.

- The article written about initial features briefly : https://github.com/shekharrajak/daru-view/wiki/All-about-daru-view
