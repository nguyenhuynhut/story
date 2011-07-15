class CharactersController < ApplicationController
  # GET /characters
  # GET /characters.xml
  uses_tiny_mce :options => {
    :theme => 'advanced',
    :theme_advanced_resizing => true,
    :theme_advanced_resize_horizontal => false,
    :theme_advanced_buttons2 => "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",
    :plugins => %w{ table fullscreen }
  }
  auto_complete_for :story, :name
  before_filter :from_story_show
  sortable_attributes :first_name ,:last_name
  before_filter :permission , :only => [:edit , :destroy]
  def auto_complete_for_story_name
    @stories = Story.find(:all , :conditions => ["name like (?) and archived = ?", "%" + params[:story][:name].to_s + "%", false],:order => 'name asc')
    render :partial => 'shoots/story'
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
    if params[:character]
      if params[:character][:first_name] != nil and params[:character][:first_name] != ''
        query_string = query_string + " AND UPPER(first_name) LIKE :first_name"
        conditions[:first_name] = "%" + params[:character][:first_name].strip.upcase + "%"
      end
      if params[:character][:last_name] != nil and params[:character][:last_name] != ''
        query_string = query_string + " AND UPPER(last_name) LIKE :last_name"
        conditions[:last_name] = "%" + params[:character][:last_name].strip.upcase + "%"
      end
    else
      if Story.find_by_id(session[:story_id])
        query_string = query_string + " AND story_id = :story_id"
        conditions[:story_id] = session[:story_id]
      end
    end

    @characters = Character.where("created_at IS NOT NULL" + query_string, conditions).find(:all ,:order => sort_order).paginate :page => params[:page],:per_page => params[:character] ? params[:character][:record_number] : 10


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

  # GET /characters/1
  # GET /characters/1.xml
  def show
    @character = Character.find(params[:id])
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @character }
    end
  end

  # GET /characters/new
  # GET /characters/new.xml
  def new
    @character = Character.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @character }
    end
  end

  # GET /characters/1/edit
  def edit
    @character = Character.find(params[:id])
  end

  # POST /characters
  # POST /characters.xml
  def create
    @character = Character.new(params[:character])
    if params[:story]
      if params[:story][:name] != nil and params[:story][:name].strip != ''
        story = Story.find_by_name(params[:story][:name].strip)
        if story

          @character.story_id = story.id
        end
      end
    end
    respond_to do |format|
      if @character.save
        if params[:avatar] then
          @character.save_avatar(params[:avatar])
        end
        format.html { redirect_to(@character, :notice => 'Character was successfully created.') }
        format.xml  { render :xml => @character, :status => :created, :location => @character }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @character.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /characters/1
  # PUT /characters/1.xml
  def update
    @character = Character.find(params[:id])
    if params[:story]
      if params[:story][:name] != nil and params[:story][:name].strip != ''
        story = Story.find_by_name(params[:story][:name].strip)
        if story

          @character.story_id = story.id
        end
      else
        @character.story_id = nil
      end
    end
    respond_to do |format|
      if @character.update_attributes(params[:character])
        if params[:avatar] then
          @character.save_avatar(params[:avatar])
        end
        format.html { redirect_to(@character, :notice => 'Character was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @character.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /characters/1
  # DELETE /characters/1.xml
  def destroy
    @character = Character.find(params[:id])
    @character.destroy

    respond_to do |format|
      format.html { redirect_to(characters_url) }
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
    logger.info session[:userid]
    if session[:userid] != nil and Staff.find_by_userid(session[:userid]).is_senior_producer == nil and Staff.find_by_userid(session[:userid]).is_assignment_editor == nil and Staff.find_by_userid(session[:userid]).is_producer == nil
      flash[:notice] = "You don't have access to this section."
      redirect_to '/'
    end
  end
  def tag_list
    @story = Story.find_by_id(session[:story_id])
    if @story == nil
      redirect_to :controller => 'stories' ,:action => 'index'
      return
    end
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    conditions = {}
    conditions[:story_id] = @story.id
    @characters = Character.where("story_id = :story_id", conditions).find(:all ,:order => sort_order).paginate :page => params[:page],:per_page => params[:character] ? params[:character][:record_number] : 10
    if params[:character]
      if params[:character][:tag_list] != nil and params[:character][:tag_list] != ''

        tag_list = params[:character][:tag_list].split(',')
        @characters = Character.where("story_id = :story_id", conditions).tagged_with(tag_list,  :any => true).find(:all ,:order => sort_order).paginate :page => params[:page],:per_page => params[:character] ? params[:character][:record_number] : 10
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
end
