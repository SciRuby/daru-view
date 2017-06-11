# coding: utf-8

module LazyHighCharts
  module LayoutHelper
    private

    def encapsulate_js(core_js)
      if request_is_xhr?
        js_output = "#{js_start} #{core_js} #{js_end}"
      # Turbolinks.version < 5
      elsif defined?(Turbolinks) && request_is_referrer?
        js_output =<<-EOJS
        #{js_start}
          var f = function(){
            document.removeEventListener('page:load', f, true);
            #{core_js}
          };
          document.addEventListener('page:load', f, true);
        #{js_end}
        EOJS
      # Turbolinks >= 5
      elsif defined?(Turbolinks) && request_turbolinks_5_tureferrer?
        js_output =<<-EOJS
        #{js_start}
          document.addEventListener("turbolinks:load", function() {
            #{core_js}
          });
        #{js_end}
        EOJS
      else
        js_output =<<-EOJS
        #{js_start}
          #{core_js}
        #{js_end}
        EOJS
      end

      if defined?(raw)
        return raw(js_output)
      else
        return js_output
      end
    end

    def js_start
      <<-EOJS
        <script type="text/javascript">
        $(function() {
      EOJS
    end

    def js_end
      <<-EOJS
        });
        </script>
      EOJS
    end
  end
end

