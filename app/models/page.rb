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
      logger.warn ['Environment ', ENV['RAILS_ENV']]
      if ENV['RAILS_ENV'] == 'production'
        logger.warn 'Headless'
        headless = Headless.new
        headless.start
        logger.warn 'Headless started'
      end

      profile = Selenium::WebDriver::Firefox::Profile.new
      browser = Watir::Browser.new :firefox

      logger.warn browser.inspect

      pages = Page.where(original_html: nil, status: 'succeed').order(:url).limit(2)
      pages.each do |page|
        begin
          logger.warn ['----','going to visit ', page.url]
          browser.goto page.url
          page.original_html = browser.html
          page.title = browser.title
          page.save
        rescue Exception => e
          logger.warn e.inspect
        end
      end
      browser.close
      if ENV['RAILS_ENV'] == 'production'
        headless.destroy
        logger.warn 'Headless destroyed'
      end
    rescue Exception => e
      logger.warn e.inspect
    end
  end

end
