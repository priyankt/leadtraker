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
      leadtype = user.leadTypes.get(params[:lead_type_id])
      leadstage = LeadStage.new(:name => params[:stage_name])
      leadtype.leadStages << leadstage
      if leadtype.valid?
        success = leadtype.save
        # rescue DataMapper::SaveFailureError => e
        # logger.error e.resource.errors.inspect
        ret = {:id => leadstage.id}
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
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
    else
      leadstage = user.leadTypes.leadStages.get(params[:stage_id])
      if leadstage.valid?
        success = leadstage.update(:name => params[:stage_name])
        if success
          # rescue DataMapper::SaveFailureError => e
          # logger.error e.resource.errors.inspect
          ret = {:success => 1}
          status 200
        else
          ret = {:success => 0, :errors => ['Error while updating lead stage']}
          status 400
        end
        
      else
        errors = leadStage.errors.to_hash
        ret = {:success => 0, :errors => errors}
        status 404
      end
    end
    
    ret.to_json
  end

  # delete lead stage id
  delete '/api/stages/:id' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      stage = user.leadTypes.leadStages.get(params[:id])
      if stage.nil?
        ret = {:success => 0, :errors => ['Invalid Lead Stage']}
        status 404
      else
        stage.destroy
        ret = {:success => 1}
        status 200
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
    eTypes = EmailType.all(:id.gt => params[:id])
    eTypes.to_json(:exclude => [:created_at, :updated_at])
  end

  # get phone types
  get 'api/phone_types' do
    pTypes = PhoneType.all(:id.gt => params[:id])
    pTypes.to_json(:exclude => [:created_at, :updated_at])
  end

  # Get contacts params[:page], params[:keyword]
  get '/api/contacts' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      if params.has_key?("keyword")
        userContacts = user.contacts.all(:name.like => '%' + params[:keyword] + '%', :offset => (params[:page].to_i - 1) * 10, :limit => 10)
      else
        userContacts = user.contacts.all(:offset => (params[:page].to_i - 1) * 10, :limit => 10)
      end
      contacts = Array.new
      userContacts.each do |userContact|
        c = Hash.new
        c = c.merge(userContact.attributes)
        c[:contactPhones] = userContact.contactPhones.all()
        c[:contactEmails] = userContact.contactEmails.all()
        contacts.push(c)
      end
      ret = contacts
      status 200
    end

    ret.to_json
  end

  # Save new contact params[:contact] - json, return contact_id
  # TODO: Also save contact for lender/affiliate
  post '/api/contacts/' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      contact_data = JSON.parse params[:contact]
      contact = Contact.new(contact_data)
      user.contacts << contact
      if user.valid?
        begin
          user.contacts.save
          user.affiliates.each do |affiliate|
            affiliate_contact = Contact.new(contact_data)
            affiliate.contacts << affiliate_contact
            if affiliate.valid?
              affiliate.contacts.save
            end
          end
        rescue DataMapper::SaveFailureError => e
          status 400
          ret = {:success => 0, :errors => e.resource.errors}
        end
        ret = {:id => contact.id}
        status 201
      else
        errors = user.errors.to_hash
        ret = {:success => 0, :errors => errors}
        status 400
      end
    end

    ret.to_json
  end

  # Update contact
  put '/api/contacts/:id' do
  end

  # Get leads, :type can be 1-active, 2-inactive, 3-closed
  # params[:page]
  get '/api/leads/:type' do
    # id, type, source, reference, contactname, contact_phone, contact_email, lead_date,
    # is_contacted
  end

  # Given lead :id, return all details of the lead
  # Also get shared appointments & notes for this lead
  get '/api/leads/:id' do
    # 
  end

  # Params[:lead_type], params[:source_id], params[:reference], params[:contacted] set leaduser contact_date
  # Params[:contact_id], params[:note], params[:address], params[:city], params[:state], params[:zip].
  # Add leads to affiliate as well
  # set source as 'agent referral' by default for lender
  # let lead type be null for lender.
  post '/api/leads' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      lead_data = Hash.new
      lead_user_data = Hash.new

      lead_user_data[:leadType_id] = params[:lead_type]
      lead_user_data[:leadSource_id] = params[:source_id]
      if params[:contacted]
        lead_user_data[:contacted] = true
        lead_user_data[:contact_date] = Time.now
      end
      lead_user_data[:contact_id] = params[:contact_id]
      lead_user_data[:notes] = [{:text => params[:note]}]
      lead_user_data[:user] = user

      lead_data[:reference] = params[:reference]
      lead_data[:prop_address] = params[:address]
      lead_data[:prop_city] = params[:city]
      lead_data[:prop_state] = params[:state]
      lead_data[:prop_zip] = params[:zip]

      #lead_user_data[:lead] = [lead_data]
      lead_data[:leadUsers] = [lead_user_data]

      #leadUser = LeadUser.new(lead_user_data)
      lead = Lead.new(lead_data)
      #puts lead.inspect
      
      if lead.valid?
        begin
          lead.save
          user.affiliates.each do |affiliate|
            lead_user_data[:user] = affiliate
            lead_user_data[:lead_id] = lead.id
            affiliate_lead_user = LeadUser.new(lead_user_data)
            if affiliate_lead_user.valid?
              affiliate_lead_user.save
            else
              errors = affiliate_lead_user.errors.to_hash
              ret = {:success => 0, :errors => errors}
              status 400
            end
          end
        rescue DataMapper::SaveFailureError => e
          status 400
          ret = {:success => 0, :errors => e.resource.errors}
        end
        ret = {:id => lead.id}
        status 201
      else
        #errors = user.errors.to_hash.merge(lead.errors.to_hash.merge(leadUser.errors.to_hash))
        errors = lead.errors.to_hash
        ret = {:success => 0, :errors => errors}
        status 400
      end
    end

    ret.to_json
  end

  # Add note to lead :id, params[:description], params[:shared]
  post '/api/notes/:id' do

  end

  # Update note :note_id, params[:description], params[:shared]
  put '/api/notes/:id' do
  end

  # Add Appointment to lead :lead_id, params[:description], params[:shared]
  # params[:dttm], params[:title]
  post '/api/appointments/:id' do

  end

  # Add Appointment :appointment_id, params[:description], params[:shared]
  # params[:dttm], params[:title]
  put '/api/appointments/:id' do

  end

  # Add financial data for lead lead_id, params[:finance]
  post '/api/finance/:id' do
  end

  # Update financial data for financial_id, params[:finance]
  put '/api/finance/:id' do
  end

  # Update contract date params[:dttm]
  put 'api/contract_date/:id' do
  end

  # Update closed date params[:dttm]
  put 'api/closed_date/:id' do
  end

  # Update property address params[:address], params[:city], params[:state], params[:zip]
  # :id is lead id
  put 'api/property_address/:id' do
  end

  # Set contacted for lead id params[:]
  put 'api/set_contacted/:id' do
  end



  # OLD CODE: Add new lead
  post '/api/leads' do
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
