require 'bcrypt'
require 'uuidtools'
require 'dm-serializer/to_json'

Leadtraker.controllers  do
  # get :index, :map => "/foo/bar" do
  #   session[:foo] = "bar"
  #   render 'index'
  # end

  # get :sample, :map => "/sample/url", :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  before do

    invalid = false
    if request.path_info =~ /^\/api\/*/
      if !env["HTTP_AUTH_KEY"].nil?
        user_key = env['HTTP_AUTH_KEY']
        user = User.first(:user_key => user_key)
        if user.nil?
          invalid = true
        end
      else
        invalid = true
      end
      
      if(invalid)
        # if invalis request then send 401 not authorized                                                                                                       
        throw(:halt, [401, "Not Authorized"])
      end
    end
    
  end

  get '/' do
    "This is a placeholder page for now. We will replace this with nice homepage."
  end

  post '/login' do
    # get email                                                                                                                                               
    email = params[:email]

    # get user for this email                                                                                                                                 
    user = User.first(:email => email)
    passwd_hash = BCrypt::Engine.hash_secret(params[:passwd], user.salt)
    ret = {:success => 0}
    if user.passwd == passwd_hash
      # assign unique auth key to this user                                                                                                                   
      user.user_key = UUIDTools::UUID.random_create
      if user.save
        status 201
        ret = {:success => 1, :user_key => user.user_key}
      else
        status 401
      end
    else
      status 401
    end

    ret.to_json

  end

  post '/register' do
      # get email, user type and passwd from params                                                                                                             
      newUser = {}
      newUser[:email] = params[:email] if params.has_key?("email")
      newUser[:type] = params[:type] if params.has_key?("type")
      newUser[:first_name] = params[:first_name] if params.has_key?("first_name")
      newUser[:last_name] = params[:last_name] if params.has_key?("last_name")
      newUser[:phone] = params[:phone] if params.has_key?("phone")
      newUser[:company] = params[:company] if params.has_key?("company")
      newUser[:address] = params[:address] if params.has_key?("address")
      newUser[:city] = params[:city] if params.has_key?("city")
      newUser[:state] = params[:state] if params.has_key?("state")
      newUser[:zip] = params[:zip] if params.has_key?("zip")
      passwd = params[:passwd] if params.has_key?("passwd")

      # generate salt for this user
      newUser[:salt] = BCrypt::Engine.generate_salt
      # encrypt passwd using salt
      newUser[:passwd] = BCrypt::Engine.hash_secret(passwd, newUser[:salt])
      # generate random key
      newUser[:user_key] = UUIDTools::UUID.random_create
      # create user object
      user = User.new(newUser)

      # if user is valid, then save to db
      if user.valid?
        user.save
        ret = {:success => 1, :user_key => newUser[:user_key]}
        status 201
      else
        errors = user.errors.to_hash
        ret = {:success => 0, :errors => errors}
        status 412
      end

      ret.to_json

  end

  get '/logout' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ''}
    else
      user.update(:user_key => nil)
      ret = {:success => 1, :errors => ''}
    end
    ret.to_json
  end

  get '/list' do
    @users = User.all(:order => [:id.desc], :limit => 20)
    @users.to_json(:exclude => [:passwd, :salt, :user_key ])
    #@users.to_json
  end

  get '/api/1' do
    test = {
      '1' => 'test',
      '2' => 'test1'
    }
    test.to_json
  end

end
