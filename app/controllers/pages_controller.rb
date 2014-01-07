require "nokogiri"
require "pp"

class PagesController < ApplicationController
  before_action :set_page, only: [:show, :edit, :update, :destroy]

  def import

  end

  def failed_to_visit_pages
    @pages = Page.where.not(status: 'succeed').order(:url)
  end

  def upload
    begin
      file = params[:file]
      xml = Nokogiri::XML open(file.path)
      set = xml.css('string')
      set = set.select {|node| node.content.start_with?('http://') && !node.content.include?('localhost')}
      set = set.map do |node|
        node.content = node.content.chomp('/')
        node.content
      end
      set = set.sort
      set[0..set.size-1].each_index do |i|
        # set[i] = 'http://www.skeptik.net/conspir/moonhoax.htm#moonwind'
        trunk1 = set[i].split('/') unless set[i].nil? #["http:", "", "www.skeptik.net", "conspir", "moonhoax.htm#moonwind"]
        stub1 = set[i].gsub("/" + trunk1.last,'') unless trunk1.nil? #'http://www.skeptik.net/conspir/'

        trunk2 = set[i+1].split('/') unless set[i+1].nil?
        stub2 = set[i+1].gsub("/" + trunk2.last,'') unless trunk2.nil?

        set[i] = nil if stub1 == stub2 && !stub1.nil?
      end
      set = set.compact.uniq
      set.each do |url|
        page = Page.find_by_url(url) || Page.create(url: url)
      end
      redirect_to pages_path, success: 'Import succeed'
    rescue
      redirect_to pages_path, alert: 'Import failed'
    end

  end
  # GET /pages
  # GET /pages.json
  def index
    case params[:type]
    when 'all'
      @pages = Page.all.order(:url)
    when 'failed'
      @pages = Page.where.not(status: 'succeed').order(:url)
    else
      @pages = Page.all.order(:url)
    end

  end

  # GET /pages/1
  # GET /pages/1.json
  def show
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # GET /pages/1/edit
  def edit
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(page_params)

    respond_to do |format|
      if @page.save
        format.html { redirect_to @page, notice: 'Page was successfully created.' }
        format.json { render action: 'show', status: :created, location: @page }
      else
        format.html { render action: 'new' }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to @page, notice: 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page.destroy
    respond_to do |format|
      format.html { redirect_to pages_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_page
    @page = Page.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def page_params
    params.require(:page).permit(:url, :status)
  end
end
