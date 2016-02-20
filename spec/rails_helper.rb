require 'pry'
# encoding: utf-8
# frozen_string_literal: true
require 'rails/all'
require 'rspec/rails'
require 'test_app/config/environment'

ActiveRecord::Migration.maintain_test_schema!

# set up db
# be sure to update the schema if required by doing
# - cd spec/support/rails_app
# - rake db:migrate
ActiveRecord::Schema.verbose = false
# load 'test_app/db/schema.rb' # db agnostic
require 'spec_helper'
