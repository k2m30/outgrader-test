require 'csv'

class Page < ActiveRecord::Base
  def self.to_csv
      CSV.generate do |csv|
        csv << column_names
        all.each do |page|
          csv << page.attributes.values_at(*column_names)
        end
      end
    end
    
    def html
      begin
        pages = Page.where(original_html: nil, status: 'succeed').order(:url).limit(2)

        p 'Environment' + ENV['RAILS_ENV']
        if ENV['RAILS_ENV'] == 'production'
          p 'Headless'
          headless = Headless.new
          headless.start
          p 'Headless started'
        end
        profile = Selenium::WebDriver::Firefox::Profile.new
        browser = Watir::Browser.new :firefox
      
        pages.each do |page|
          begin
            p '----','going to visit ' + page.url
            browser.goto page.url
            page.original_html = browser.html
            page.title = browser.title
            page.save
          rescue Exception => e
          end

        end
        browser.close
        if ENV['RAILS_ENV'] == 'production'
          headless.destroy
          logger.warn 'Headless destroyed'
        end
      rescue Exception => e
      end
    end
end
