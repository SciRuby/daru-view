require 'daru/view/plot'
require 'daru/view/table'

module Daru
  module View
    module Rails
      module ViewHelper
        extend ActiveSupport::Concern

        included do
          helper_method('daru_chart', 'daru_table') if respond_to?(:helper_method)
        end

        def daru_chart(data=[], options={})
          Daru::View::Plot.new(data, options).div.html_safe
        end

        def daru_table(data=[], options={})
          Daru::View::Table.new(data, options).div.html_safe
        end
      end
    end
  end
end
