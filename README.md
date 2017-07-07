# Daru::View

Daru (Data Analysis in RUby) is a library for analysis, manipulation and visualization of data. Daru-view is for easy and interactive plotting in web application & IRuby notebook. It can work in frameworks like Rails, Sinatra, Nanoc and hopefully in others too.

It is a plugin gem to Data Analysis in RUby(Daru) for visualisation of data

## Documentation :

[http://www.rubydoc.info/github/Shekharrajak/daru-view/](http://www.rubydoc.info/github/Shekharrajak/daru-view/)

## Examples :

- [IRuby notebook examples](http://nbviewer.jupyter.org/github/shekharrajak/daru-view/tree/master/spec/dummy_iruby/)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'daru-view', git: 'https://github.com/Shekharrajak/daru-view.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install daru-view

## Usage

### Use in IRuby notebook

- Create separate folder and Gemfile inside it. Add minimum these lines in it

```ruby
source "http://rubygems.org"

# iruby dependencies
gem 'rbczmq'
gem 'ffi-rzmq'
gem 'iruby'

# fetch from the github master branch
gem "daru", git: 'https://github.com/SciRuby/daru.git'
gem "nyaplot", git: 'https://github.com/SciRuby/nyaplot.git'
gem 'daru-view', :git => 'https://github.com/shekharrajak/daru-view.git'
```

- Now do `bundle install` and run `iruby notebook`

- You may like to try some examples that is added in specs : [spec/dummy_iruby/](http://nbviewer.jupyter.org/github/shekharrajak/daru-view/tree/master/spec/dummy_iruby/)

### Use in web application

- Add this line in your Gemfile :
```ruby
gem 'daru-view', :git => 'https://github.com/shekharrajak/daru-view.git'
gem "daru", git: 'https://github.com/SciRuby/daru.git'
gem "nyaplot", git: 'https://github.com/SciRuby/nyaplot.git'
```

_Note_ : Right now, in daru-view gemspec file `daru` and `nyaplot` is not added as development_dependency. Since daru-view required the latest github version of the Daru and Nyaplot gem and we can't fetch gem from the github in the gemspec.

#### Rails application

- In controller, do the data analysis process using daru operations and get the DataFrame/Vectors.

- Set a plotting library using e.g. `Daru::View.plotting_library = :highcharts`

- In view, add the required JS files (for the plotting library), in head tag (generally) using the line , e.g. : `Daru::View.dependent_script(:highcharts)`

The line `<%=raw Daru::View.dependent_script(:highcharts) %>` for rails app , must be added in the layout file of the application.

- Plot library using by passing `data` and `options` :

HighCharts example :

```ruby

# set the library, to plot charts
Daru::View.plotting_library = :highcharts

# options for the charts
opts = {
      chart: {defaultSeriesType: 'line'},
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

      plotOptions: {
          # this is not working. Find the bug
          # series: {
          #     pointStart: 43934
          # }
      },
  }

# data for the charts
series_dt = ([{
      name: 'Tokyo',
      data: [7.0, 6.9, 9.5, 14.5, 18.4, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6]
  }, {
      name: 'London',
      data: [3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]
  }])

# initialize
@line_graph = Daru::View::Plot.new(series_dt, opts)

# Add this line in your view file, where you want to see you graph in web application. (It will put the html code of the line graph in web page)

<%=raw @line_graph.div %>

# Now refresh the page, you will be able to see your graph.

```


Nyaplot example :

```ruby

# set the library, to plot charts (Default it is nyaplot only)
Daru::View.plotting_library = :nyaplot


# options for the charts
opts = {
  type: :bar
}

# Vector data for the charts
data_vector = Daru::Vector.new [:a, :a, :a, :b, :b, :c], type: :category
data_df = Daru::DataFrame.new({
  a: [1, 2, 4, -2, 5, 23, 0],
  b: [3, 1, 3, -6, 2, 1, 0],
  c: ['I', 'II', 'I', 'III', 'I', 'III', 'II']
  })
data_df.to_category :c

# initialize
@bar_graph1 = Daru::View::Plot.new(data_vector ,opts)
@bar_graph2 = Daru::View::Plot.new(data_df, type: :bar, x: :c)

# Add this line in your view file, where you want to see you graph in web application. (It will put the html code of the line graph in web page)

<%=raw @bar_graph1.div %>
<%=raw @bar_graph2.div %>

# Now refresh the page, you will be able to see your graph.

```

- User can try examples, that is added in spec/dummy_rails. To setup the rails app, run following commands :

```
bundle install
bundle exec rails s

```
Now go to the http://localhost:3000/nyaplot to see the Nyaplot examples or http://localhost:3000/highcharts to see the Highcharts examples.


#### Sinatra application


- In view, add the required JS files (for the plotting library), in head tag (generally) using the line , e.g. : `Daru::View.dependent_script(:highcharts)`

The line `<%= Daru::View.dependent_script(:highcharts) %>` for sinatra app , must be added in the layout file of the application(inside the head tag).


```ruby
# In side the `app.rb` user must do data analysis process using daru features and define the Daru::View::Plot class instance variables to pass into the webpages in the `view` files. You will understand this better, if you will try to run sinatra app present in the `spec/dummy_sinatra`

# Add this line in your view file, where you want to see you graph in web application. (It will put the html code of the line graph in web page)

<%= @line_graph.div %>

<%= @bar_graph1.div %>
<%= @bar_graph2.div %>

# Now refresh the page, you will be able to see your graph.

```

- User can try examples, that is added in spec/dummy_sinatra. To setup the rails app, run following commands :

```
bundle install
bundle exec ruby app.rb

```
Now go to the http://localhost:4567/nyaplot to see the Nyaplot examples or http://localhost:4567/highcharts to see the Highcharts examples.


#### Nanoc application

Most of the things similar to Rails application (syntax of the view part of the application).

- User can try examples, that is added in spec/dummy_nanoc. To setup the rails app, run following commands :

```
bundle install
bundle exec nanoc
bundle exec nanoc view

```
Now go to the http://localhost:3000/nyaplot to see the Nyaplot examples or http://localhost:3000/highcharts to see the Highcharts examples.


## Update to latest js library. Additional command line

  To update to the current highcharts.js directly from http://code.highcharts.com/",  you can always run

    rake highcharts:update

  And it will be copied to your adapters/js/highcharts_js directory.

  Similarly for other libraries.

  To update the all libraries Javascript file, run this command :

    rake update_all


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Generally I prefer to use `bundle console` for testing few codes and experimenting the gem repo.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shekharrajak/daru-view. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

Pick a feature from the Roadmap or the issue tracker or think of your own and send me a Pull Request!

For details see [CONTRIBUTING](CONTRIBUTING.md).

## Acknowledgments

This software has been developed by [Shekhar Prasad Rajak](https://github.com/Shekharrajak) as a product in Google Summer of Code 2017 (GSoC2017). Visit the [blog posts](http://shekharrajak.github.io/gsoc_2017_posts/) or [mailing list of SciRuby](https://groups.google.com/forum/#!forum/sciruby-dev) to see the progress of this project.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

