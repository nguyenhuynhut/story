class AirdatesController < ApplicationController
  # GET /airdates
  # GET /airdates.xml
  before_filter :from_story_show
  before_filter :permission , :only => [:edit , :destroy]
  def index
    @story = Story.find_by_id(session[:story_id])
    if @story == nil
      redirect_to :controller => 'stories' ,:action => 'index'
      return
    end
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    @airdates = @story.airdates
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @airdates }
    end
  end

  # GET /airdates/1
  # GET /airdates/1.xml
  def show
    @airdate = Airdate.find(params[:id])
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @airdate }
    end
  end

  # GET /airdates/new
  # GET /airdates/new.xml
  def new
    @airdate = Airdate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @airdate }
    end
  end

  # GET /airdates/1/edit
  def edit
    @airdate = Airdate.find(params[:id])
  end

  # POST /airdates
  # POST /airdates.xml
  def create
    @airdate = Airdate.new(params[:airdate])
    @airdate.story_id = session[:story_id]
    respond_to do |format|
      if @airdate.save
        format.html { redirect_to(@airdate, :notice => 'Airdate was successfully created.') }
        format.xml  { render :xml => @airdate, :status => :created, :location => @airdate }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @airdate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /airdates/1
  # PUT /airdates/1.xml
  def update
    @airdate = Airdate.find(params[:id])

    respond_to do |format|
      if @airdate.update_attributes(params[:airdate])
        format.html { redirect_to(@airdate, :notice => 'Airdate was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @airdate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /airdates/1
  # DELETE /airdates/1.xml
  def destroy
    @airdate = Airdate.find(params[:id])
    @airdate.destroy

    respond_to do |format|
      format.html { redirect_to(airdates_url) }
      format.xml  { head :ok }
    end
  end
  def from_story_show


    if session[:story_id] == nil and session[:story_id] == ''

      flash[:error] = "You don't have access to this section."
      redirect_to :controller => 'stories' ,:action => 'index'
    end
  end
  def permission
    if session[:userid] == nil or session[:userid] == ''

      flash[:notice] = "You don't have access to this section."
      redirect_to '/'
    end
    if session[:userid] != nil and Staff.find_by_userid(session[:userid]).is_senior_producer == nil and Staff.find_by_userid(session[:userid]).is_assignment_editor == nil and Staff.find_by_userid(session[:userid]).is_producer == nil
      flash[:notice] = "You don't have access to this section."
      redirect_to '/'
    end
  end
end
