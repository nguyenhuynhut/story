class ShootsController < ApplicationController
  # GET /shoots
  # GET /shoots.xml
  uses_tiny_mce :options => {
    :theme => 'advanced',
    :theme_advanced_resizing => true,
    :theme_advanced_buttons2 => "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",
    :theme_advanced_resize_horizontal => false,
    :plugins => %w{ table fullscreen }
  }
  auto_complete_for :story, :name


  before_filter :from_story_show
  sortable_attributes :date , :crew_requirements  ,:location, :name
  before_filter :permission , :only => [:edit , :destroy]
  def auto_complete_for_story_name
    @stories = Story.find(:all , :conditions => ["name like (?) and archived = ?", "%" + params[:story][:name].to_s + "%", false],:order => 'name asc')
    render :partial => 'story'
  end
  def index


    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    query_string = ""
    conditions = {}
    if params[:story]
      if params[:story][:name] != nil and params[:story][:name].strip != ''
        story = Story.find_by_name(params[:story][:name].strip)
        if story
          query_string = query_string + " AND  story_id = :story_id"
          conditions[:story_id] = story.id
        end
      end
    end
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

      if params[:shoot][:name] != nil and params[:shoot][:name] != ''
        query_string = query_string + " AND UPPER(name) LIKE :name"
        conditions[:name] = "%" + params[:shoot][:name].strip.upcase + "%"
      end
    else
      if Story.find_by_id(session[:story_id])
        query_string = query_string + " AND story_id = :story_id"
        conditions[:story_id] = session[:story_id]
      end
    end

    @shoots = Shoot.where("created_at IS NOT NULL" + query_string, conditions).find(:all ,:order => sort_order).paginate :page => params[:page],:per_page => params[:shoot] ? params[:shoot][:record_number] : 10
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
    @shoot.check_mail = false
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
      if  params[:shoot][:senior_approval] == '1'
        @shoot.approver = @valid_staff
      end
      @shoot.staff = @valid_staff
    end
    if params[:story]
      if params[:story][:name] != nil and params[:story][:name].strip != ''
        story = Story.find_by_name(params[:story][:name].strip)
        if story

          @shoot.story_id = story.id
        end
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
      @shoot.staff = @valid_staff
    end
    params[:shoot][:check_mail] = false
    if params[:story]
      if params[:story][:name] != nil and params[:story][:name].strip != ''
        story = Story.find_by_name(params[:story][:name].strip)
        if story

          @shoot.story_id = story.id
        end
      else
        @shoot.story_id = nil
      end
    end
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
