require 'bcrypt'
require 'uuidtools'
require 'dm-serializer/to_json'
require 'json'

Leadtraker.controllers  do

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

  # Logout user
  get '/logout' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 400
    else
      user.update(:user_key => nil)
      ret = {:success => 1, :errors => ''}
      status 200
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

      if params.has_key?("type")
        if newUser[:type] == 1
          newUser[:leadTypes] = [
            {
              :name => 'Buyer',
              :leadStages => [
                {:name => 'Appointment'},
                {:name => 'Listing'},
                {:name => 'Contract'},
                {:name => 'Closed'},
              ],
            },
            {
              :name => 'Seller',
              :leadStages => [
                {:name => 'Appointment'},
                {:name => 'Listing'},
                {:name => 'Contract'},
                {:name => 'Closed'},
              ],
            }
          ]
          newUser[:leadSources] = [
            {:name => 'VoicePad'},
            {:name => 'Realtor.com'},
            {:name => 'Sign Call'},
            {:name => 'Referral'},
            {:name => 'HomeCards'},
            {:name => 'Web Site'},
          ]
        else
          newUser[:leadTypes] = [
          {
            :name => 'Purchase',
            :leadStages => [
              {:name => 'Application'},
              {:name => 'Pull Credit Report'},
              {:name => 'Initial Docs List'},
              {:name => 'Pre-Approved Letter'},
              {:name => 'Under Contract'},
              {:name => 'Initial Disclosures'},
              {:name => 'Updated Docs List'},
              {:name => 'Submit to Processing'},
              {:name => 'Appraisal'},
              {:name => 'Initial underwriting'},
              {:name => 'Collect Conditions'},
              {:name => 'Submit for CtoC'},
              {:name => 'Documents'},
              {:name => 'Closed'},
            ],
          },
          {
            :name => 'Re-Finance',
            :leadStages => [
              {:name => 'Application'},
              {:name => 'Pull Credit Report'},
              {:name => 'Initial Docs List'},
              {:name => 'Initial Disclosures'},
              {:name => 'Updated Docs List'},
              {:name => 'Submit to Processing'},
              {:name => 'Appraisal'},
              {:name => 'Initial underwriting'},
              {:name => 'Collect Conditions'},
              {:name => 'Submit for CtoC'},
              {:name => 'Documents'},
              {:name => 'Closed'},
            ],
          },
        ]
        newUser[:leadSources] = [
          {:name => 'Agent Referral'},
          {:name => 'ePropertySites'},
          {:name => 'Web Site'},
          {:name => 'Referral'},
          {:name => 'Past Client'},
        ]
        end
      end
      
      # create user object
      user = User.new(newUser)
      
      # if user is valid, then save to db
      if user.valid?
        user.save
	# rescue DataMapper::SaveFailureError => e
	# logger.error e.resource.errors.inspect
        ret = {:success => 1, :user_key => newUser[:user_key]}
        status 201
      else
        errors = user.errors.to_hash
        ret = {:success => 0, :errors => errors}
        status 412
      end

      ret.to_json

  end

  # return all starges for lead type id ':id'
  get '/api/stages/:id' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      status 404
      ret = {:success => 0, :errors => ['Invalid User']}
    else
      leadStages = user.leadTypes(:id => params[:id]).leadStages.all()
      ret = leadStages
    end
    ret.to_json
  end

  # new lead stage
  post '/api/stages/:lead_type_id' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
    else
      leadType = user.leadTypes.get(params[:lead_type_id])
      leadStage = LeadStage.new(:name => params[:stage_name], :leadTypes => leadType)
      if leadStage.valid?
        leadStage.save
        # rescue DataMapper::SaveFailureError => e
        # logger.error e.resource.errors.inspect
        ret = {:success => 1}
        status 200
      else
        errors = user.errors.to_hash
        ret = {:success => 0, :errors => errors}
        status 404
      end
    end
    
    ret.to_json
  end

  # update lead stage param[:stage_name]
  put '/api/stages/:stage_id' do

  end

  # delete lead stage id
  delete '/api/stages/:id' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      status 404
      ret = {:success => 0, :errors => ['Invalid User']}
    else
      stage = user.leadTypes.leadStages.get(params[:id])
      if stage.nil?
        status 404
        ret = {:success => 0, :errors => ['Invalid Lead Stage']}
      else
        status 200
        stage.destroy
        ret = {:success => 1}
      end
    end
    
    ret.to_json

  end

  # return all lead types for this user
  get '/api/types' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      leadTypes = user.leadTypes.all()
      ret = leadTypes
      status 200
    end
    ret.to_json
  end

  # New lead type params[:name], params[:description]
  post '/api/types' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      leadtype = LeadType.new(:name => params[:name], :description => params[:description])
      user.leadTypes << leadtype
      if user.valid?
        user.save
        ret = {:id => leadtype.id}
        status 200
      else
        errors = user.errors.to_hash
        ret = {:success => 0, :errors => errors}
        status 400
      end
    end
    
    ret.to_json
  end

  # rename lead type params[:name], params[:description]
  put '/api/types/:id' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      leadtype = user.leadTypes.get(params[:id])
      if leadtype.nil?
        ret = {:success => 0, :errors => ['Invalid Lead Type']}
        status 404
      else
        success = leadtype.update(:name => params[:name], :description => params[:description])
        if not success
          ret = {:success => 0, :errors => ['Invalid Lead Type']}
          status 404
        else
          ret = {:success => 1}
          status 200
        end
      end
    end

    ret.to_json
  end

  # return all sources for this user
  get '/api/sources' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      sources = user.leadSources.all()
      ret = sources
      status 200
    end
    
    ret.to_json(:exclude => [:created_at, :updated_at])

  end

  # new source params[:name]
  post '/api/sources' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      source = LeadSource.new(:name => params[:name])
      user.leadSources << source
      if user.valid?
        user.save
        ret = {:id => source.id}
        status 200
      else
        errors = user.errors.to_hash
        ret = {:success => 0, :errors => errors}
        status 400
      end
    end
    
    ret.to_json
  end

  # get email types
  get 'api/email_types' do
    eTypes = EmailType.all()
    eTypes.to_json(:exclude => [:created_at, :updated_at])
  end

  # get phone types
  get 'api/phone_types' do
    pTypes = PhoneType.all()
    pTypes.to_json(:exclude => [:created_at, :updated_at])
  end

  # Add new lead
  post '/api/lead' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ''}
    else
      lead_types = JSON.parse params[:lead]
      user.leadTypes << lead_types
      if user.valid?
        user.save
        # rescue DataMapper::SaveFailureError => e
        # logger.error e.resource.errors.inspect
        ret = {:success => 1}
        status 200
      else
        errors = user.errors.to_hash
        ret = {:success => 0, :errors => errors}
        status 400
      end
    end

    ret.to_json
  end

  get '/list' do
    @users = User.all(:order => [:id.desc], :limit => 20)
    @users.to_json(:exclude => [:passwd, :salt, :user_key ])
    #@users.to_json
  end

  get '/leadtypes' do
    @leadTypes = LeadType.all()
    @leadTypes.to_json()
  end

  get '/api/1' do
    test = {
      '1' => 'test',
      '2' => 'test1'
    }
    test.to_json
  end

end
