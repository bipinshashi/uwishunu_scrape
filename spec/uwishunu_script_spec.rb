require 'spec_helper'
require_relative '../uwishunu_script'

describe "Parsing Uwishunu" do
	let(:uwishunu_file) {File.join(File.dirname(__FILE__),"fixtures/uwishunu_sample.html")}
	let(:event) { Event.new(uwishunu_file)}
	# it "should be able to load the document from the web" do
	# 	Event.new
	# end

	it "should be able to determine the cost of the event" do
		event.get_cost.should == "Free"
	end

	it "should be able to determine the location of the event" do
		event.get_location.should == "AIGA Philadelphia, 72 N. 2nd Street"
	end

	# it "should be able to determine the dates of the event" do
	# 	event.get_dates.should == "2013-02-01 00:00:00 -0500, 2013-03-31 00:00:00 -0400"
	# end

	it "should be able to determine the title of the event" do
		event.get_title.should == "AIGA Philadelphia Presents MAPnificent: Artists Use Maps, February 1-March 31"
	end

	it "should be able to get the source link of the event" do
		event.get_source_link.should == "http://www.uwishunu.com/2013/01/aiga-philadelphia-presents-mapnificent-artists-use-maps-february-1-march-31/"
	end
end