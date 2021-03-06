# Copyright:: (c) Autotelik Media Ltd 2011
# Author ::   Tom Statter
# Date ::     Aug 2011
# License::   MIT
#
# Details::   Specs for Excel aspect of Active Record Loader
#
require File.dirname(__FILE__) + '/spec_helper'

require 'erb'
require 'csv_generator'

include DataShift

describe 'CSV Generator' do

  before(:all) do
    results_clear("*.csv")

    @klazz = Project
    @assoc_klazz = Category
  end

  before(:each) do
    MethodDictionary.clear
    MethodDictionary.find_operators( @klazz )
    MethodDictionary.find_operators( @assoc_klazz )
  end

  it "should be able to create a new csv generator" do
    generator = CsvGenerator.new( 'dummy.csv' )

    generator.should_not be_nil
  end

  it "should generate template .csv file from model" do

    expected = result_file('project_template_spec.csv')

    gen = CsvGenerator.new( expected )

    gen.generate(Project)

    expect(File.exists?(expected)).to eq true

    puts "Can manually check file @ #{expected}"

    csv = CSV.read(expected)

    headers = csv[0]

    [ "title", "value_as_string", "value_as_text", "value_as_boolean", "value_as_datetime", "value_as_integer", "value_as_double"].each do |check|
      headers.include?(check).should == true
    end
  end

  # has_one  :owner
  # has_many :milestones
  # has_many :loader_releases
  # has_many :versions, :through => :loader_releases
  # has_and_belongs_to_many :categories

  it "should include all associations in template .csv file from model" do

    expected = result_file('project_plus_assoc_template_spec.csv')

    gen = CsvGenerator.new(expected)

    gen.generate_with_associations(Project)

    expect( File.exists?(expected)).to eq true

    csv = CSV.read(expected)

    headers = csv[0]

    ["owner", "milestones", "loader_releases", "versions", "categories"].each do |check|
      headers.include?(check).should == true
    end
  end


  it "should enable us to exclude associations by type in template .csv file" do

    expected = result_file('project_plus_some_assoc_template_spec.csv')

    gen = CsvGenerator.new(expected)

    options = {:exclude => :has_many }

    gen.generate_with_associations(Project, options)

    expect(File.exists?(expected)).to eq true #, "Failed to find expected result file #{expected}"

    csv = CSV.read(expected)

    headers = csv[0]

    headers.include?('title').should == true
    headers.include?('owner').should == true

    ["milestones", "loader_releases", "versions", "categories"].each do |check|
      headers.should_not include check
    end

  end


  it "should enable us to exclude certain associations in template .csv file " do

    expected = result_file('project_plus_some_assoc_template_spec.csv')

    gen = CsvGenerator.new(expected)

    options = {:remove => [:milestones, :versions] }

    gen.generate_with_associations(Project, options)

    expect(File.exists?(expected)).to eq true#, "Failed to find expected result file #{expected}"

    csv = CSV.read(expected)

    headers = csv[0]

    ["title", "loader_releases", "owner", "categories"].each do |check|
      headers.should include check
    end


    ["milestones",  "versions", ].each do |check|
      headers.should_not include check
    end

  end


   it "should enable us to remove standard rails feilds from template .csv file " do

    expected = result_file('project_plus_some_assoc_template_spec.csv')

    gen = CsvGenerator.new(expected)

    options = {:remove_rails => true}

    gen.generate_with_associations(Project, options)

    expect(File.exists?(expected)).to eq true#, "Failed to find expected result file #{expected}"

    csv = CSV.read(expected)

    headers = csv[0]

    ["id", "updated_at", "created_at"].each do |check|
      headers.should_not include check
    end


  end
end
