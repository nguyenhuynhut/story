class StaffsController < ApplicationController
  # GET /staffs
  # GET /staffs.xml
  sortable_attributes :userid ,:first_name ,:last_name ,:title ,:email ,:phone
  before_filter :staff_is_admin ,:only => [:index ,:destroy]
  def index
    query_string = ""
    conditions = {}
    if params[:staff]
      if params[:staff][:userid] != nil and params[:staff][:userid] != ''
        query_string = query_string + " AND UPPER(userid) LIKE :userid"
        conditions[:userid] = "%" + params[:staff][:userid].strip.upcase + "%"
      end
      if params[:staff][:first_name] != nil and params[:staff][:first_name] != ''
        query_string = query_string + " AND UPPER(first_name) LIKE :first_name"
        conditions[:first_name] = "%" + params[:staff][:first_name].strip.upcase + "%"
      end
      if params[:staff][:last_name] != nil and params[:staff][:last_name] != ''
        query_string = query_string + " AND UPPER(last_name) LIKE :last_name"
        conditions[:last_name] = "%" + params[:staff][:last_name].strip.upcase + "%"
      end
      if params[:staff][:email] != nil and params[:staff][:email] != ''
        query_string = query_string + " AND UPPER(email) LIKE :email"
        conditions[:email] = "%" + params[:staff][:email].strip.upcase + "%"
      end
      if params[:staff][:title] != nil and params[:staff][:title] != ''
        query_string = query_string + " AND UPPER(title) LIKE :title"
        conditions[:title] = "%" + params[:staff][:title].strip.upcase + "%"
      end
      if params[:staff][:phone] != nil and params[:staff][:phone] != ''
        query_string = query_string + " AND UPPER(phone) LIKE :phone"
        conditions[:phone] = "%" + params[:staff][:phone].strip.upcase + "%"
      end
    end
    @staffs =  Staff.where("created_at IS NOT NULL" + query_string, conditions).find(:all ,:order => sort_order).paginate :page => params[:page],:per_page => params[:staff] ? params[:staff][:record_number] : 10

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

  # GET /staffs/1
  # GET /staffs/1.xml
  def show
    @staff = Staff.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @staff }
    end
  end

  # GET /staffs/new
  # GET /staffs/new.xml
  def new
    @staff = Staff.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @staff }
    end
  end

  # GET /staffs/1/edit
  def edit

    @staff = Staff.find(params[:id])
    if session[:userid] != nil and session[:userid] != ''
      if session[:userid] != 'admin'

        @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])

        if @valid_staff.id != @staff.id
          flash[:notice] = "You don't have access to this section."
          redirect_to '/'
          return
        end
      end
    else
      flash[:notice] = "You don't have access to this section."
      redirect_to '/'
      return
    end
  end

  # POST /staffs
  # POST /staffs.xml
  def create
    @staff = Staff.new(params[:staff])

    respond_to do |format|
      if @staff.save
        if params[:avatar] then
          @staff.save_avatar(params[:avatar])
        end
        format.html { redirect_to(@staff, :notice => 'Staff was successfully created.') }
        format.xml  { render :xml => @staff, :status => :created, :location => @staff }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /staffs/1
  # PUT /staffs/1.xml
  def update
    @staff = Staff.find(params[:id])

    respond_to do |format|
      if @staff.update_attributes(params[:staff])
        if params[:avatar] then
          @staff.save_avatar(params[:avatar])
        end
        format.html { redirect_to(@staff, :notice => 'Staff was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /staffs/1
  # DELETE /staffs/1.xml
  def destroy
    @staff = Staff.find(params[:id])
    @staff.destroy

    respond_to do |format|
      format.html { redirect_to(staffs_url) }
      format.xml  { head :ok }
    end
  end
  def authenticate

    @staff = Staff.new(params[:staff_form])
    #find records with userid,password
    valid_user = Staff.find(:first, :conditions => ["userid = ? and password = ?", @staff.userid, Digest::SHA1.hexdigest(@staff.password)])

    #if statement checks whether valid_user exists or not
    if valid_user
      #creates a session with username
      session[:userid]=valid_user.userid
      #redirects the user to our private page.
      redirect_to '/'
    else
      flash[:notice] = "Invalid User/Password"
      redirect_to :action=> 'login'
    end
  end

  def login
  end
  def logout
    if session[:userid]
      reset_session
      redirect_to '/'
    end
  end
  def forgot
  end
  def contact_us




  end
  def contact_staff

  end
  def send_contact_staff
    respond_to do |format|
      if verify_recaptcha( :message => "Oh! It's error with reCAPTCHA!")
        subject = params[:contact_staff][:subject]
        staff = Staff.find_by_id(params[:contact_staff][:id].to_i)
        if staff
          recipient = staff.email
          message =  params[:contact_staff][:message]
          UserMailer.contact_staff(recipient, subject, staff, message).deliver
          format.html { redirect_to(:controller => 'staffs', :action =>"index") }
        else
          format.html { redirect_to(:controller => 'staffs', :action =>"contact_staff", :contact_staff => { :error => "The staff doesn't exist in the system" ,:subject => params[:contact_staff][:subject] , :message => params[:contact_staff][:message], :id => params[:contact_staff][:id]})}
        end
      else
        format.html { redirect_to(:controller => 'staffs', :action =>"contact_staff", :contact_staff => { :error => "Oh! It's error with reCAPTCHA!" ,:subject => params[:contact_staff][:subject] , :message => params[:contact_staff][:message], :id => params[:contact_staff][:id]})}
      end
    end
  end
  def send_contact_us

    respond_to do |format|
      if verify_recaptcha( :message => "Oh! It's error with reCAPTCHA!")
        recipient = 'nhut2020@yahoo.com'
        subject = params[:contact_us][:subject]
        staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
        message =  params[:contact_us][:message]
        UserMailer.contact_us(recipient, subject, staff, message).deliver
        format.html { redirect_to(:controller => 'home', :action =>"index") }
      else
        format.html { redirect_to(:controller => 'staffs', :action =>"contact_us", :contact_us => { :error => "Oh! It's error with reCAPTCHA!" ,:subject => params[:contact_us][:subject] , :message => params[:contact_us][:message]})}
      end
    end
  end
  def sendmail
    recipient = params[:mailform][:email]
    subject = 'Get your password'
    staff = Staff.find(:first, :conditions => ["email = ? ", recipient])
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
    password = ''
    6.times { |i| password << chars[rand(chars.length)] }

    if staff
      staff.password = password
      UserMailer.forgot(recipient, subject, staff).deliver
      staff.update_attributes(:password => password)
    else
      flash[:notice] = recipient + " doesn't exist in the system"
      redirect_to '/'
      return
    end
    return if request.xhr?
    flash[:notice] = 'Message sent successfully'
    redirect_to '/'
  end
  def staff_is_admin
    if session[:userid] == nil or session[:userid] == ''

      flash[:notice] = "You don't have access to this section."
      redirect_to '/'
    end
    if session[:userid] != nil and Staff.find_by_userid(session[:userid]).userid != 'admin'
      flash[:notice] = "You don't have access to this section."
      redirect_to '/'
    end
  end
end
