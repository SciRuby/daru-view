module GoogleVisualr
  class PatternFormat < Formatter
    attr_accessor :des_col

    def initialize(format_string='')
      super
      @format_string = format_string
    end

    def src_cols=(*columns)
      @src_cols = columns.flatten
    end

    def to_js
      js = "\nvar formatter = "\
           "new google.visualization.#{self.class.to_s.split('::').last}("
      js << "'#{@format_string}'"
      js << ');'
      js << "\nformatter.format(data_table, #{@src_cols}, #{@des_col});"
    end
  end
end
