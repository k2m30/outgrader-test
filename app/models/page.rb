require 'watir-webdriver-performance'
require 'watir-webdriver'
require 'headless'
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

  def self.html
      logger.info ['Environment ', ENV['RAILS_ENV']]
      if ENV['RAILS_ENV'] == 'production'
        logger.warn 'Headless'
        headless = Headless.new
        headless.start
        logger.warn 'Headless started'
      end

      browser = Watir::Browser.new :firefox

      logger.info browser.inspect

      pages = Page.where(original_html: nil).shuffle
      pages.each do |page|
        begin
          logger.info ['----','going to visit ', page.url]
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
  end

end
