
class StoriesController < ApplicationController
  # GET /stories
  # GET /stories.xml
  uses_tiny_mce :options => {
    :theme => 'advanced',
    :theme_advanced_resizing => true,
    :theme_advanced_buttons2 => "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",
    :theme_advanced_resize_horizontal => false,
    :plugins => %w{ table fullscreen }
  }
  sortable_attributes :name , :deadline
  before_filter :permission , :only => [:edit , :destroy, :clone]
  def index
    if params[:story]
      if params[:story][:approved] == '1'
        session[:approved] = true
      else
        session[:approved] = false
      end
    else
      session[:approved] = false
    end
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    query_string = ""
    conditions = {}
    if params[:story]
      if params[:story][:name] != nil and params[:story][:name] != ''
        query_string = query_string + " AND UPPER(name) LIKE :name"
        conditions[:name] = "%" + params[:story][:name].strip.upcase + "%"
      end
     
      if params[:story][:producer_id] != nil and params[:story][:producer_id] != ''
        query_string = query_string + " AND producer_id = :producer_id"
        conditions[:producer_id] = params[:story][:producer_id]
      end
      if params[:story][:correspondent_id] != nil and params[:story][:correspondent_id] != ''
        query_string = query_string + " AND correspondent_id = :correspondent_id"
        conditions[:correspondent_id] = params[:story][:correspondent_id]
      end
      if params[:story][:editor_id] != nil and params[:story][:editor_id] != ''
        query_string = query_string + " AND editor_id = :editor_id"
        conditions[:editor_id] = params[:story][:editor_id]
      end
    end
    if params[:story]

      if params[:story][:approved] == '1'
        conditions[:approved] = true
      else
        conditions[:approved] = false
      end
      if params[:story][:archived] == '1'
        conditions[:archived] = true
      else
        conditions[:archived] = false
      end
    else
      conditions[:archived] = false
      conditions[:approved] = false
    end

    conditions[:today] = Date.today()
    @stories = Story.where("approved = :approved and deadline >= :today and archived = :archived" + query_string, conditions).find(:all ,:order => sort_order).paginate :page => params[:page],:per_page => params[:story] ? params[:story][:record_number] : 10

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

  # GET /stories/1
  # GET /stories/1.xml
  def show
    @story = Story.find(params[:id])
    session[:story_id] = params[:id]
    @shoots = Shoot.where("story_id = :story_id" , :story_id => session[:story_id] ).find(:all ,:order => 'created_at', :limit => 20)
    @webextras = Webextra.where("story_id = :story_id" , :story_id => session[:story_id] ).find(:all ,:order => 'created_at', :limit => 20)
    @characters = Character.where("story_id = :story_id", :story_id => session[:story_id] ).find(:all ,:order => 'created_at', :limit => 20)
    @airdates = Airdate.where("story_id = :story_id", :story_id => session[:story_id] ).find(:all ,:order => 'created_at', :limit => 20)
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @story }
    end
  end

  # GET /stories/new
  # GET /stories/new.xml
  def new
    if params[:story]
      if params[:story][:approved] == '1'
        session[:approved] = true
      else
        session[:approved] = false
      end
    else
      session[:approved] = false
    end
    @story = Story.new
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @story }
    end
  end

  # GET /stories/1/edit
  def edit
    @story = Story.find(params[:id])
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
  end

  # POST /stories
  # POST /stories.xml
  def create
    @story = Story.new(params[:story])
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    @story.approved = session[:approved]
    @story.check_mail = false
    @story.staff_id = @valid_staff.id
    respond_to do |format|
      if @story.save
        if session[:approved]
          format.html { redirect_to(@story, :notice => 'Story was successfully created.') }
        else
          format.html { redirect_to(@story, :notice => 'Pitch was successfully created.') }
        end
        format.xml  { render :xml => @story, :status => :created, :location => @story }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stories/1
  # PUT /stories/1.xml
  def update
    @story = Story.find(params[:id])
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    params[:story][:check_mail] = false
    @story.staff_id = @valid_staff.id
    respond_to do |format|
      if @story.update_attributes(params[:story])
        if session[:approved]
          format.html { redirect_to(@story, :notice => 'Story was successfully updated.') }
        else
          format.html { redirect_to(@story, :notice => 'Pitch was successfully updated.') }
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.xml
  def destroy
    @story = Story.find(params[:id])
    @story.destroy

    respond_to do |format|
      format.html { redirect_to(stories_url) }
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
  def tag_list

    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end

    conditions = {}

    conditions[:approved] = true

    conditions[:today] = Date.today()
    @stories = Story.where("approved = :approved and deadline >= :today" , conditions).find(:all ,:order => sort_order).paginate :page => params[:page],:per_page => params[:story] ? params[:story][:record_number] : 10
    if params[:story]
      if params[:story][:tag_list] != nil and params[:story][:tag_list] != ''

        tag_list = params[:story][:tag_list].split(',')
        @stories = Story.where("approved = :approved and deadline >= :today" , conditions).tagged_with(tag_list,  :any => true).find(:all ,:order => sort_order).paginate :page => params[:page],:per_page => params[:story] ? params[:story][:record_number] : 10
      end
    end
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
    def clone
    @story = Story.find(params[:id])
    @clone = Story.new(@story.attributes)
    @clone.save

    respond_to do |format|
      format.html { redirect_to(stories_path(:story =>{:approved => 1})) }
      format.xml  { head :ok }
    end
  end
end
