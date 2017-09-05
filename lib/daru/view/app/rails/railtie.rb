require_relative 'helpers/view_helper'

module Daru
  module View
    module Rails
      class Railtie < ::Rails::Railtie
        initializer 'daru/view' do
          ActiveSupport.on_load(:action_controller) do
            include Daru::View::Rails::ViewHelper
          end
        end
      end
    end
  end
end
