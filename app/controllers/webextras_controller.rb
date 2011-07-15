class WebextrasController < ApplicationController
  # GET /webextras
  # GET /webextras.xml
  uses_tiny_mce :options => {
    :theme => 'advanced',
    :theme_advanced_resizing => true,
    :theme_advanced_buttons2 => "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",
    :theme_advanced_resize_horizontal => false,
    :plugins => %w{ table fullscreen }
  }
  auto_complete_for :story, :name
  def auto_complete_for_story_name
    @stories = Story.find(:all , :conditions => ["name like (?) and archived = ?", "%" + params[:story][:name].to_s + "%", false],:order => 'name asc')
    render :partial => 'shoots/story'
  end
  before_filter :from_story_show, :permission , :only => [:edit , :destroy]
  sortable_attributes :title , :summary, :name
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
    if params[:webextra]
      if params[:webextra][:title] != nil and params[:webextra][:title] != ''
        query_string = query_string + " AND UPPER(title) LIKE :title"
        conditions[:title] = "%" + params[:webextra][:title].strip.upcase + "%"
      end
      if params[:webextra][:summary] != nil and params[:webextra][:summary] != ''
        query_string = query_string + " AND UPPER(summary) LIKE :summary"
        conditions[:summary] = "%" + params[:webextra][:summary].strip.upcase + "%"
      end
      if params[:webextra][:name] != nil and params[:webextra][:name] != ''
        query_string = query_string + " AND UPPER(name) LIKE :name"
        conditions[:name] = "%" + params[:webextra][:name].strip.upcase + "%"
      end
    else
      if Story.find_by_id(session[:story_id])
        query_string = query_string + " AND story_id = :story_id"
        conditions[:story_id] = session[:story_id]
      end
    end
    @webextras = Webextra.where("created_at IS NOT NULL" + query_string, conditions).find(:all ,:order => sort_order).paginate :page => params[:page],:per_page => params[:webextra] ? params[:webextra][:record_number] : 10


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

  # GET /webextras/1
  # GET /webextras/1.xml
  def show
    @webextra = Webextra.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @webextra }
    end
  end

  # GET /webextras/new
  # GET /webextras/new.xml
  def new
    @webextra = Webextra.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @webextra }
    end
  end

  # GET /webextras/1/edit
  def edit
    @webextra = Webextra.find(params[:id])
  end

  # POST /webextras
  # POST /webextras.xml
  def create
    @webextra = Webextra.new(params[:webextra])
    @webextra.check_mail = false
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    @webextra.staff_id = @valid_staff.id
    if params[:story]
      if params[:story][:name] != nil and params[:story][:name].strip != ''
        story = Story.find_by_name(params[:story][:name].strip)
        if story

          @webextra.story_id = story.id
        end
      end
    end
    respond_to do |format|
      if @webextra.save
        begin
          if params[:video] and params[:video].original_filename
            extension = File.extname(params[:video].original_filename)
            file_name = @webextra.id.to_s + '_' + Time.now.to_i.to_s
            AWS::S3::S3Object.store(sanitize_filename(file_name + extension), params[:video].read, BUCKET, :access => :public_read)
            @webextra.update_attribute('videourl' ,AWS::S3::S3Object.url_for(file_name + extension, BUCKET, :authenticated => false))

          end
        rescue
          @webextra.delete
          render :text => "Couldn't complete the upload"
          return
        end
        format.html { redirect_to(@webextra, :notice => 'Webextra was successfully created.') }
        format.xml  { render :xml => @webextra, :status => :created, :location => @webextra }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @webextra.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /webextras/1
  # PUT /webextras/1.xml
  def update
    @webextra = Webextra.find(params[:id])
    params[:webextra][:check_mail] = false
    if session[:userid] != nil and session[:userid] != ''
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
    @webextra.staff_id = @valid_staff.id
    if params[:story]
      if params[:story][:name] != nil and params[:story][:name].strip != ''
        story = Story.find_by_name(params[:story][:name].strip)
        if story

          @webextra.story_id = story.id
        end
      else
        @webextra.story_id = nil
      end
    end
    respond_to do |format|
      if @webextra.update_attributes(params[:webextra])

        if params[:video] and params[:video].original_filename
          extension = File.extname(params[:video].original_filename)
          file_name = @webextra.id.to_s + '_' + Time.now.to_i.to_s
          AWS::S3::S3Object.store(sanitize_filename(file_name + extension), params[:video].read, BUCKET, :access => :public_read)
          @webextra.update_attribute('videourl' ,AWS::S3::S3Object.url_for(file_name + extension, BUCKET, :authenticated => false))
        end

        format.html { redirect_to(@webextra, :notice => 'Webextra was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @webextra.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /webextras/1
  # DELETE /webextras/1.xml
  def destroy
    @webextra = Webextra.find(params[:id])
    @webextra.destroy

    respond_to do |format|
      format.html { redirect_to(webextras_url) }
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
  private

  def sanitize_filename(file_name)
    just_filename = File.basename(file_name)
    just_filename.sub(/[^\w\.\-]/,'_')
  end
end
