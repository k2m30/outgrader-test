require 'watir-webdriver-performance'
require 'watir-webdriver'
require 'headless'

class Testrun < ActiveRecord::Base
  def self.new_testrun(pages_id)
    begin
      logger.warn 'start'
      logger.warn ['environment= ', ENV['RAILS_ENV']]
      if ENV['RAILS_ENV'].nil? || ENV['RAILS_ENV'] == 'production'
        logger.warn 'Headless started'
        headless = Headless.new
        headless.start
      end

      profile = Selenium::WebDriver::Firefox::Profile.new
      profile.proxy = Selenium::WebDriver::Proxy.new :http => '93.125.42.249:8888', :ssl => '93.125.42.249:8888'
      profile['browser.cache.memory.enable']=false
      profile['browser.sessionhistory.max_total_viewers']=1
      browser = Watir::Browser.new :firefox, :profile => profile

      logger.warn 'browser is started'

      testrun = Testrun.new
      testrun.total = pages_id.size
      failed = 0
      passed = 0

      pages_id.each do |id|
        begin
          page = Page.find_by_id(id)
          logger.warn ['----','going to visit ' + page.url]
          browser.goto page.url

          #Returns "loading" while the document is loading, "interactive" once it is finished parsing but still loading sub-resources, and "complete" once it has loaded.
          case browser.ready_state
          when 'complete'
            passed+=1
            page.status = 'succeed'
          when 'interactive'
            failed+=1
            sleep(2)
            page.status = browser.ready_state == 'complete' ? 'succeed' : browser.ready_state
          when 'loading'
            failed+=1
            page.status = browser.ready_state
          else
            failed+=1
            page.status = 'other'
          end
          page.save
          logger.warn [passed+failed, 'visited ', page.url]
        rescue Exception => e
          failed+=1
          logger.warn ['failed',e.inspect, page.url]
          status = e.inspect
          status.length < 255 ? page.status = status : page.status = status[0..254]
          page.save
          browser.close
          # browser = Watir::Browser.new :chrome, :switches => %w['--proxy-server=93.125.42.249']
          browser = Watir::Browser.new :firefox, :profile => profile
          logger.warn 'browser is started again'
        end
      end
      testrun.passed = passed
      testrun.failed = failed
      if testrun.failed == 0 && testrun.failed + testrun.passed == testrun.total
        testrun.status = 'succeed'
      else
        testrun.status = 'failed'
      end
      testrun.save
      browser.close
      if ENV['RAILS_ENV'] == 'production'
        headless.destroy
        logger.warn 'Headless destroyed'
      end

      logger.warn 'finish'

    rescue Exception => e
      logger.warn e.inspect
      testrun.passed = passed
      testrun.failed = failed
      testrun.status = 'failed'
      testrun.save
      browser.close
      if ENV['RAILS_ENV'] == 'production'
        headless.destroy
        logger.warn 'Headless destroyed'
      end

    end
  end
end
