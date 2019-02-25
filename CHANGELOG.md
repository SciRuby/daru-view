## 0.2.5 (2019-02-25)

**Fixes:**

- Fixed Rubocop offenses coming from version 0.60 #125 (by @Shekharrajak)
- Updated README.md and Contribution Guide #129, #131, #133, 
    #139, #141 (by @Shekharrajak)
- Removed the duplicate highcharts.css #145 (by @[snpd25](/snpd25)) 
- [Majaor Fix] Windows installation error fix #147 (by @kojix2 & @Shekharrajak)

## 0.2.4 (2017-08-29)

**Major Enhancements:**

- Added Highstock feature of HighCharts plotting: #89 (by @Prakriti-nith)
- Added HighMaps feature of HighCharts plotting: #92 (by @Prakriti-nith)
- Added Custom Styling CSS feature of HighCharts plotting: #93
(by @Prakriti-nith)
- Exporting HighCharts to different formats: #94 (by @Prakriti-nith)
- Added ChartWrapper feature of GoogleCharts: #95 (by @Prakriti-nith)
- Import data from google spreadsheet: PR #88 (by @Prakriti-nith)
- Added ChartEditor feature of GoogleCharts plotting: #96 (by @Prakriti-nith)
- Multiple Charts having different (or same plotting library)
in a single row(or in single cell in IRuby notebook): #97 (by @Prakriti-nith)
- Different formatters feature of GoogleCharts: #110 (by @Prakriti-nith)
- Require dependent JS for the plotting libraries
GoogleCharts/HighCharts/DataTables in Rails application.js file: #115
(by @Prakriti-nith)


**Minor Enhancements:**

- Exporting charts in PNG formate for GoogleCharts: #98 (by @Prakriti-nith)
- Handling Events in GoogleCharts: #100 (by @Prakriti-nith)
- Added a method to load dependent scripts for multiple adapters: #107
(by @Prakriti-nith)
- Rake Task to add new adapter templates: #112 (by @Prakriti-nith)
- (by @Prakriti-nith)
- export_html method, generate_html method is implemented and load large set of data piece by piece using datatables adaptor: #104 (by @Prakriti-nith)

**Fixes:**

- Fix generate_html method in googlecharts.rb: #84 (by @Prakriti-nith)
- Update JS files for the libraries: #83 (by @rohitner)
- Improved the coverage report.
- Replace shekharrajak with SciRuby: #75 (by @Abhishek-sopho)

**Note:**

* [GSoC 2018 project](https://github.com/SciRuby/daru-view/wiki/GSoC-2018---Progress-Report)

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
