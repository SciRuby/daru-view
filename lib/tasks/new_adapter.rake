def extract_adapter_template_code(file_name, template_code_str)
  template_code_str << "module Daru"
  template_code_str << "\n  module View"
  template_code_str << "\n    module Adapter"
  template_code_str << "\n      module #{file_name.capitalize}Adapter"
  template_code_str << "\n        extend self # rubocop:disable Style/ModuleFunction"
  template_code_str << append_method('init', ['data', 'options', '_user_options'])
  template_code_str << "\n"
  template_code_str << append_method('export_html_file', ['plot', "path='./plot.html'"])
  template_code_str << "\n"
  template_code_str << append_method('show_in_iruby', ['plot'])
  template_code_str << "\n"
  template_code_str << append_method('init_script')
  template_code_str << "\n"
  template_code_str << append_method('generate_body', ['plot'])
  template_code_str << "\n"
  template_code_str << append_method('init_iruby')
  template_code_str << "\n      end"
  template_code_str << "\n    end"
  template_code_str << "\n  end"
  template_code_str << "\nend"
  template_code_str << "\n"
end

def append_method(method_name, params=nil)
  method_str = "\n        def #{method_name}"
  if params
    method_str << '('
    method_str << params.join(', ')
    method_str << ')'
  end
  method_str << append_method_body(method_name, params)
  method_str << "\n        end"
end

def append_method_body(_method_name, _params)
  method_body = "\n          # TODO"
  method_body << "\n          raise NotImplementedError, 'Not yet implemented'"
  method_body
end

namespace :new do  
  desc "Generate a sample template for the new adapter"
  task :adapter do
    print "Creating new adapter..."
    ARGV.each { |a| task a.to_sym do ; end }
    file_name = ARGV[1].to_s.downcase
    path = File.expand_path(
            '../daru/view/adapters/' + file_name + '.rb', __dir__
          )
    template_code_str = ''
    extract_adapter_template_code(file_name, template_code_str)
    File.write(path, template_code_str)
    puts "Done."
  end
end
