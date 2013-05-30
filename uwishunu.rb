require 'rubygems'
require 'bundler'
require 'open-uri'
require 'cgi'
require 'csv'
Bundler.require

class Event

	def initialize(link="http://www.uwishunu.com/2013/01/aiga-philadelphia-presents-mapnificent-artists-use-maps-february-1-march-31/")
		@doc = Nokogiri::HTML(open(link))
	end

	def get_info_element
		@doc.css('.info p:contains("When:")')
	end

	def get_google_cal_params
		link = @doc.css('div.savepoppad a').css('.savegoogle')[1].attributes["href"].value
		CGI.parse(URI.parse(link).query)
	end

	def get_title
		@doc.xpath("//div[@id='posts' and @class='single']/div[1][@class='post']/h2/a").text
	end

	def get_image_link
		begin
		@doc.css(".wp-caption").children[0].attributes['src'].value
		rescue => ex
			puts "No image- #{ex.message}"
			return
		end
	end

	def get_details
		begin
			get_google_cal_params["details"][0].split("<BR>").first
		rescue => ex
			puts "details exception - #{ex.message}"
			get_google_cal_params["details"][0]
		end
	end

	def get_source_link
		URI.extract(get_google_cal_params["details"][0]).last
	end

	def get_cost
		return if get_info_element.text.scan(/^Cost:.*\n/).empty?
		get_info_element.text.scan(/^Cost:.*\n/).first.gsub("Cost:","").strip
	end

	def get_location
		return if get_info_element.text.scan(/^Where:.*\n/).empty?
		get_info_element.text.scan(/^Where:.*\n/).first.gsub("Where:","").strip
	end

	def get_dates
		begin
			date = get_google_cal_params["dates"][0]
			start_date,end_date = date.split("/")[0],date.split("/")[1]
			return DateTime.parse(start_date).to_time, DateTime.parse(end_date).to_time
		rescue => ex
			puts "error in date parsing - #{ex.message}"
			return [0,0]
		end
	end

end


def start_scrape(date="march-20-2013")
	i = 1
	page_end = false
	CSV.open("uwishunu_events_#{date}.csv","ab") do |csv|
		csv << ["title","start_time","end_time","details","src_link","img_link","location","cost"]
		while page_end == false	
			begin
				doc = Nokogiri::HTML(open("http://www.uwishunu.com/events/#{date}/page/#{i}"))
				event_page_links = []
				doc.css(".post h2 a").each do |link|
					event_page_links << link.attributes["href"].value
				end

				event_page_links.each do |event_page|
					event = Event.new(event_page)
					csv << [event.get_title, event.get_dates[0], event.get_dates[1], event.get_details,
					event.get_source_link, event.get_image_link, event.get_location, event.get_cost]
				end	
				puts "Done with page #{i}"
		    i+=1 #next page
		  rescue => ex
		  	page_end = true
		  	puts "#{ex.message}"
		  	puts "#{i} -- parsing done"
		  end
		end
	end
end


start_scrape(Date.parse(ARGV.first).to_date.strftime("%B-%d-%Y").downcase)
