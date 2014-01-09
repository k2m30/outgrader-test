require 'watir-webdriver-performance'
require 'watir-webdriver'
require 'headless'

class TestrunsController < ApplicationController
  before_action :set_testrun, only: [:show, :edit, :update, :destroy]

  # GET /testruns
  # GET /testruns.json
  def index
    @testruns = Testrun.all
  end

  # GET /testruns/1
  # GET /testruns/1.json
  def show
  end

  def create_original_html
    Rails.logger.level = 3
    Page.first.html
    redirect_to testruns_path
  end
  # GET /testruns/new
  def new
    begin
      p 'start'
      if ENV['RAILS_ENV'] == 'production'
        logger.warn 'Headless started'
        headless = Headless.new
        headless.start
      end
      
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile.proxy = Selenium::WebDriver::Proxy.new :http => '93.125.42.249:8888', :ssl => '93.125.42.249:8888'
      browser = Watir::Browser.new :firefox, :profile => profile

      # browser = Watir::Browser.new :chrome, :switches => %w['--proxy-server=93.125.42.249']
      p 'browser is started'
      case params[:type]
      when 'all'
        pages = Page.all.shuffle
      when 'new'
        pages = Page.where(status: nil)
      when 'failed'
        pages = Page.where.not(status: 'succeed')
      when 'single_page'
        id = params[:id] || Page.first.id
        pages = Page.where(id: id)
      else
        pages = Page.where(status: nil)
      end

      testrun = Testrun.new
      testrun.total = pages.size
      failed = 0
      passed = 0

      pages.each do |page|
        begin
          p '----','going to visit ' + page.url
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
          # if browser.ready_state == 'complete'
          #
          #             passed+=1
          #             page.status = 'succeed'
          #             page.save
          #           else
          #             failed+=1
          #             page.status = browser.ready_state
          #             page.save
          #           end
          p [passed+failed, 'visited ', page.url]
        rescue Exception => e
          failed+=1
          p ['failed',e.inspect, page.url]
          status = e.inspect
          status.length < 255 ? page.status = status : page.status = status[0..254]
          page.save
          browser.close
          # browser = Watir::Browser.new :chrome, :switches => %w['--proxy-server=93.125.42.249']
          browser = Watir::Browser.new :firefox, :profile => profile
          p 'browser is started again'
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
      
      p 'finish'
      redirect_to testruns_path, success: 'Testrun succesful'
    rescue Exception => e
      testrun.passed = passed
      testrun.failed = failed
      testrun.status = 'failed'
      testrun.save
      if ENV['RAILS_ENV'] == 'production'
        headless.destroy
        logger.warn 'Headless destroyed'
      end      
      redirect_to testruns_path, alert: 'Testrun failed'
    end

  end

  # GET /testruns/1/edit
  def edit
  end

  # POST /testruns
  # POST /testruns.json
  def create
    @testrun = Testrun.new(testrun_params)

    respond_to do |format|
      if @testrun.save
        format.html { redirect_to @testrun, notice: 'Testrun was successfully created.' }
        format.json { render action: 'show', status: :created, location: @testrun }
      else
        format.html { render action: 'new' }
        format.json { render json: @testrun.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /testruns/1
  # PATCH/PUT /testruns/1.json
  def update
    respond_to do |format|
      if @testrun.update(testrun_params)
        format.html { redirect_to @testrun, notice: 'Testrun was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @testrun.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /testruns/1
  # DELETE /testruns/1.json
  def destroy
    @testrun.destroy
    respond_to do |format|
      format.html { redirect_to testruns_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_testrun
    @testrun = Testrun.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def testrun_params
    params.require(:testrun).permit(:status, :passed, :failed, :total)
  end
end
