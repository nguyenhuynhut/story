class ShootsController < ApplicationController
  # GET /shoots
  # GET /shoots.xml
  before_filter :from_story_show
  sortable_attributes :date , :crew_requirements  ,:location
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
    query_string = ""
    conditions = {}
    if params[:shoot]
      if params[:shoot][:crew_requirements] != nil and params[:shoot][:crew_requirements] != ''
        query_string = query_string + " AND UPPER(crew_requirements) LIKE :crew_requirements"
        conditions[:crew_requirements] = "%" + params[:shoot][:crew_requirements].strip.upcase + "%"
      end
      if params[:shoot][:location] != nil and params[:shoot][:location] != ''
        query_string = query_string + " AND UPPER(location) LIKE :location"
        conditions[:location] = "%" + params[:shoot][:location].strip.upcase + "%"
      end
      if params[:shoot][:cameraperson_id] != nil and params[:shoot][:cameraperson_id] != ''
        query_string = query_string + " AND cameraperson_id = :cameraperson_id"
        conditions[:cameraperson_id] = params[:shoot][:cameraperson_id]
      end
    end
    conditions[:story_id] = @story.id
    logger.info params[:shoot]
    @shoots = Shoot.where("story_id = :story_id" + query_string, conditions).find(:all ,:order => sort_order).paginate :page => params[:page],:per_page => params[:shoot] ? params[:shoot][:record_number] : 10
    respond_to do |format|
      format.html # index.html.erb
      format.js {
        render :update do |page|
          # 'page.replace' will replace full "results" block...works for this example
          # 'page.replace_html' will replace "results" inner html...useful elsewhere
          page.replace 'results', :partial => 'search_results'
        end
      }
    end
  end

  # GET /shoots/1
  # GET /shoots/1.xml
  def show
    @shoot = Shoot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shoot }
    end
  end

  # GET /shoots/new
  # GET /shoots/new.xml
  def new
    @shoot = Shoot.new
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shoot }
    end
  end

  # GET /shoots/1/edit
  def edit
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    @shoot = Shoot.find(params[:id])
  end

  # POST /shoots
  # POST /shoots.xml
  def create
    @shoot = Shoot.new(params[:shoot])
    @shoot.story_id = session[:story_id]
    @shoot.check = false
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
      if  params[:shoot][:senior_approval] == '1'
        @shoot.approver = @valid_staff
      end
    end
    respond_to do |format|
      if @shoot.save
        format.html { redirect_to(@shoot, :notice => 'Shoot was successfully created.') }
        format.xml  { render :xml => @shoot, :status => :created, :location => @shoot }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shoot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shoots/1
  # PUT /shoots/1.xml
  def update
    @shoot = Shoot.find(params[:id])
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
      if params[:shoot][:senior_approval] == '1'
        @shoot.approver = @valid_staff
      end
    end
    params[:shoot][:check] = false
    respond_to do |format|
      if @shoot.update_attributes(params[:shoot])
        format.html { redirect_to(@shoot, :notice => 'Shoot was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shoot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shoots/1
  # DELETE /shoots/1.xml
  def destroy
    @shoot = Shoot.find(params[:id])
    @shoot.destroy

    respond_to do |format|
      format.html { redirect_to(shoots_url) }
      format.xml  { head :ok }
    end
  end
      def permission
    if session[:userid] == nil or session[:userid] == ''

      flash[:notice] = "You don't have access to this section."
      redirect_to '/'
    end
    logger.info session[:userid]
    if session[:userid] != nil and Staff.find_by_userid(session[:userid]).is_senior_producer == nil and Staff.find_by_userid(session[:userid]).is_assignment_editor == nil and Staff.find_by_userid(session[:userid]).is_producer == nil
      flash[:notice] = "You don't have access to this section."
      redirect_to '/'
    end
  end
  def from_story_show


    if session[:story_id] == nil and session[:story_id] == ''

      flash[:error] = "You don't have access to this section."
      redirect_to :controller => 'stories' ,:action => 'index'
    end
  end
end
