require 'net/http'
require 'net/https'
class HomeController < ApplicationController
  def index
    if session[:userid]
      @valid_staff = Staff.find(:first, :conditions => ["userid = ? ", session[:userid]])
    end
  end
  def sign_in_google
    #client = GData::Client::DocList.new
    #next_url = 'http://dantri.heroku.com'
    #secure = false  # set secure = true for signed AuthSub requests
    #sess = true
    #domain = 'dantri.heroku.com'  # force users to login to a Google Apps hosted domain
    #authsub_link = client.authsub_url(next_url, secure, sess, domain)


    #   redirect_to authsub_link

    next_param = "http://" + request.host_with_port + "/home/complete_sign_in_google"
    logger.info next_param
    logger.info 'ta'
    scope_param =  'http://www.google.com/m8/feeds/contacts/default/full?max-results=0'

    secure_param = "0"
    session_param = "1"
    root_url = "https://www.google.com/accounts/AuthSubRequest"
    query_string = "?scope=#{scope_param}&session=#{session_param}&secure=#{secure_param}&next=#{next_param}"
    redirect_to root_url + query_string
  end
  def complete_sign_in_google
    # logger.info 'aa'
    client = GData::Client::DocList.new
    client.authsub_token = params[:token] # extract the single-use token from the URL query params
    session[:token] = client.auth_handler.upgrade()
    client.authsub_token = session[:token] if session[:token]
    #logger.info client.auth_handler.info
    # redirect_to '/'
    logger.info feed = client.get('http://www.google.com/m8/feeds/contacts/default/full?max-results=0').to_xml


    logger.info feed.elements['title'].text
    logger.info feed.elements['author'].elements['name'].text
    logger.info feed.elements['author'].elements['email'].text
    if feed and  params[:token]
      if feed.elements['author'] and feed.elements['author'].elements['email'].text
        @staff_email = Staff.find_by_email(feed.elements['author'].elements['email'].text)
        @staff_userid = Staff.find_by_userid(feed.elements['author'].elements['email'].text)
        if (@staff_email and @staff_email.token != nil) or (@staff_userid and @staff_userid.token != nil)
          session[:userid] = @staff_email ? @staff_email.userid : @staff_userid.userid
                      redirect_to '/'
            return
        else
          if @staff_email or @staff_userid
            flash[:notice] = "You don't have access to this section."
            redirect_to '/'
            return
          else
            chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
            password = ''
            6.times { |i| password << chars[rand(chars.length)] }
            @staff = Staff.new(:userid => feed.elements['author'].elements['email'].text, :email => feed.elements['author'].elements['email'].text , :token => params[:token], :password => password ,:first_name => feed.elements['author'].elements['name'].text, :last_name => '-' , :title => feed.elements['title'].text ,:phone => '-')
            if @staff.save()
              session[:userid]  = @staff.userid
                     redirect_to '/'
                     return
            else
              logger.info @staff.errors
              flash[:notice] = "You don't have access to this section"
              redirect_to '/'
              return
            end
          end
        end
      else
        flash[:notice] = "You don't have access to this section."
        redirect_to '/'
        return
      end
    else
      flash[:notice] = "You don't have access to this section."
      redirect_to '/'
      return
    end



  end
end
