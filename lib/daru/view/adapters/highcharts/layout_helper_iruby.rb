# coding: utf-8

module LazyHighCharts
  module LayoutHelper

    def high_chart_iruby(placeholder, object, &block)
      object.html_options.merge!({:id => placeholder})
      object.options[:chart][:renderTo] = placeholder
      high_graph_iruby(placeholder, object, &block).concat(content_tag("div", "", object.html_options))
    end

    def high_graph_iruby(placeholder, object, &block)
      build_html_output_iruby("Chart", placeholder, object, &block)
    end


    private

    def build_html_output_iruby(type, placeholder, object, &block)
      core_js =<<-EOJS
        var options = #{options_collection_as_string(object)};
        #{capture(&block) if block_given?}
        window.chart_#{placeholder.underscore} = new Highcharts.#{type}(options);
      EOJS

      encapsulate_js_iruby core_js
    end

    def encapsulate_js_iruby(core_js)
      if request_is_xhr?
        js_output = "#{js_start_iruby} #{core_js} #{js_end_iruby}"
      # Turbolinks.version < 5
      elsif defined?(Turbolinks) && request_is_referrer?
        js_output =<<-EOJS
        #{js_start_iruby}
          var f = function(){
            document.removeEventListener('page:load', f, true);
            #{core_js}
          };
          document.addEventListener('page:load', f, true);
        #{js_end_iruby}
        EOJS
      # Turbolinks >= 5
      elsif defined?(Turbolinks) && request_turbolinks_5_tureferrer?
        js_output =<<-EOJS
        #{js_start_iruby}
          document.addEventListener("turbolinks:load", function() {
            #{core_js}
          });
        #{js_end_iruby}
        EOJS
      else
        js_output =<<-EOJS
        #{js_start_iruby}
          #{core_js}
        #{js_end_iruby}
        EOJS
      end

      if defined?(raw)
        return raw(js_output)
      else
        return js_output
      end
    end

    def js_start_iruby
      <<-EOJS
        <script type="text/javascript">
        $(function() {
      EOJS
    end

    def js_end_iruby
      <<-EOJS
        });
        </script>
      EOJS
    end
  end
end



