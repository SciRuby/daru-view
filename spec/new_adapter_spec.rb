require 'spec_helper'
require 'rake'

describe 'new:adapter' do
  it "runs the task new:adapter" do
    Rake.application.rake_require 'tasks/new_adapter'
    expect { Rake::Task['new:adapter'].invoke }.not_to raise_exception
  end
end
