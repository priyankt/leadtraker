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
    eTypes = EmailType.all()
    eTypes.to_json(:exclude => [:created_at, :updated_at])
  end

  # get phone types
  get 'api/phone_types' do
    pTypes = PhoneType.all()
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
          ret = {:id => contact.id}
          status 201
        rescue DataMapper::SaveFailureError => e
          status 400
          ret = {:success => 0, :errors => e.resource.errors}
        end
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
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      begin
        c = user.contacts.get(params[:id])
        contact_data = JSON.parse params[:contact]
        # iterate over phones
        contact_data["contactPhones"].each do |phone|
          if phone.has_key?("id")
            phoneObj = c.contactPhones.get(phone["id"])
            phoneObj.update(phone)
          else
            phoneObj = ContactPhone.new(phone)
            c.contactPhones << phoneObj
            c.save
          end
        end
        # iterate over emails
        contact_data["contactEmails"].each do |email|
          if email.has_key?("id")
            emailObj = c.contactEmails.get(email["id"])
            emailObj.update(email)
          else
            emailObj = ContactEmail.new(email)
            c.contactEmails << emailObj
            c.save
          end
        end
        # update contact
        contact_data.delete("contactPhones")
        contact_data.delete("contactEmails")
        c.update(contact_data)
        status 200
        ret = {:success => 1}
        # TODO: Update affiliate contact as well
      rescue DataMapper::SaveFailureError => e
        status 400
        ret = {:success => 0, :errors => e.resource.errors}
      end
    end

    ret.to_json
  end

  # Get leads, :type can be 1-active, 2-inactive, 3-closed
  # params[:page]
  get '/api/leads' do
    # id, type, source, reference, contactname, contact_phone, contact_email, lead_date,
    # is_contacted
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      leadUsers = user.leadUsers.all(:status => params[:status], :offset => (params[:page].to_i - 1) * 10, :limit => 10)
      leads = Array.new
      leadUsers.each do |lu|
        contact = lu.contact
        source = lu.leadSource
        lead = lu.lead
        type = lu.leadType

        leadHash = Hash.new
        leadHash[:id] = lead.id
        leadHash[:type] = type.id
        leadHash[:source] = source.id
        leadHash[:reference] = lead.reference
        leadHash[:contact_name] = contact.name
        leadHash[:contact_phone] = nil
        leadHash[:contact_email] = nil
        if not contact.contactPhones.empty?
          leadHash[:contact_phone] = contact.contactPhones.first.phone
        end
        if not contact.contactEmails.empty?
          leadHash[:contact_email] = contact.contactEmails.first.email
        end
        leadHash[:lead_date] = lead.created_at
        leadHash[:is_contacted] = lu.contacted

        leads.push(leadHash)
      end
      ret = leads
      status 200
    end

    ret.to_json
  end

  # Given lead :id, return all details of the lead
  # Also get shared appointments & notes for this lead
  get '/api/leads/:id' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      lead = user.leads.get(params[:id])
      leadUser = lead.leadUsers.first(:user => user)

      c = Hash.new
      c = c.merge(lead.attributes)

      ctact = Hash.new
      ctact = ctact.merge(leadUser.contact.attributes)
      ctact[:contactPhones] = Array.new
      leadUser.contact.contactPhones.each do |cp|
        ctact[:contactPhones].push(cp)
      end
      ctact[:contactEmails] = Array.new
      leadUser.contact.contactEmails.each do |ce|
        ctact[:contactEmails].push(ce)
      end
      c[:contact] = ctact

      c[:notes] = leadUser.notes
      c[:appointments] = leadUser.appointments
      fnance = Hash.new
      if not leadUser.finance.nil?
        fnance = fnance.merge(leadUser.finance.attributes)
        fnance[:financeExpenses] = Array.new
        leadUser.finance.financeExpenses.each do |fe|
          fnance[:financeExpenses].push(fe)
        end
      end
      c[:finance] = fnance

      stages = Array.new
      leadUser.leadType.leadStages.each do |defaultStageData|
        stageHash = Hash.new
        stageHash = stageHash.merge(defaultStageData.attributes)
        stageHash[:dttm] = 0
        lead.stageDates.each do |updatedStageData|
          if updatedStageData.leadStage.id == defaultStageData.id
            stageHash[:dttm] = updatedStageData.dttm
          end
        end
        stages.push(stageHash)
      end
      c[:stages] = stages
      ret = c
    end

    ret.to_json
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

  # Add note to lead :id, params[:text], params[:shared]
  post '/api/lead/:id/note' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      note = Note.new(:text => params[:text], :shared => params[:shared])
      lu = LeadUser.first(:lead_id => params[:id])
      lu.notes << note
      if lu.valid?
        lu.notes.save
        status 201
        ret = {:id => note.id}
      else
        status 400
        ret = {:success => 0, :errors => lu.errors.to_hash}
      end
    end

    ret.to_json
  end

  # Update note params[:note_id], params[:description], params[:shared]
  # id is lead id
  put '/api/lead/:id/note' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      n = user.leadUsers.notes.get(params[:note_id])
      if not n.nil?
        n.text = params[:text] if params.has_key?("text")
        n.shared = params[:shared] if params.has_key?("shared")
        if n.valid?
          n.save
          ret = {:success => 1}
          status 200
        else
          status 400
          ret = {:success => 0, :errors => n.errors.to_hash}  
        end
      else
        status 400
        ret = {:success => 0, :errors => ['Invalid appointment for current user']}
      end
    end

    ret.to_json
  end

  # Add Appointment to lead :lead_id, params[:description], params[:shared]
  # params[:dttm], params[:title]
  post '/api/lead/:id/appointment' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      appointment = Appointment.new(:description => params[:description], :title => params[:title], :shared => params[:shared], :dttm => params[:dttm])
      lu = LeadUser.first(:lead_id => params[:id], :user => user)
      lu.appointments << appointment
      if lu.valid?
        lu.appointments.save
        status 201
        ret = {:id => appointment.id}
      else
        status 400
        ret = {:success => 0, :errors => lu.errors.to_hash}
      end
    end

    ret.to_json
  end

  # Add Appointment params[:id], params[:description], params[:shared]
  # params[:dttm], params[:title]
  put '/api/lead/:id/appointment' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      apt = user.leadUsers.appointments.get(params[:appointment_id])
      if not apt.nil?
        apt.description = params[:description] if params.has_key?("description")
        apt.shared = params[:shared] if params.has_key?("shared")
        apt.dttm = params[:dttm] if params.has_key?("dttm")
        apt.title = params[:title] if params.has_key?("title")
        if apt.valid?
          apt.save
          ret = {:success => 1}
          status 200
        else
          status 400
          ret = {:success => 0, :errors => apt.errors.to_hash}  
        end
      else
        status 400
        ret = {:success => 0, :errors => ['Invalid appointment for current user']}
      end
    end

    ret.to_json
  end

  # Add financial data for lead lead_id, params[:finance]
  post '/api/lead/:id/finance' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      lu = LeadUser.first(:lead_id => params[:id], :user_id => user.id)
      finance_data = JSON.parse params[:finance]
      lu.finance = Finance.new(finance_data)
      if lu.valid?
        lu.save
        ret = {:id => lu.finance.id}
        status 201
      else
        status 400
        ret = {:success => 0, :errors => lu.errors.to_hash}
      end
    end

    ret.to_json
  end

  # Update financial data for params[:financial_id], params[:finance]
  put '/api/lead/:id/finance' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      lu = LeadUser.first(:lead_id => params[:id], :user => user)
      finance_data = JSON.parse params[:finance]
      if finance_data.has_key?("financeExpenses")
        finance_data["financeExpenses"].each do |fe_data|
          feObj = FinanceExpense.get(fe_data["id"])
          feObj.update(fe_data)
        end
        finance_data.delete("financeExpenses")
      end
      lu.finance.update(finance_data)
      ret = {:success => 1}
      status 200
    end

    ret.to_json
  end

  # Update contract date params[:dttm]
  put 'api/lead/:id/contract_date' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      lu = LeadUser.first(:lead_id => params[:id], :user_id => user.id)
      lu.contract_date = params[:dttm]
      if lu.valid?
        lu.save
        ret = {:success => 1}
        status 200
      else
        status 400
        ret = {:success => 0, :errors => lu.errors.to_hash}
      end
    end

    ret.to_json
  end

  # Update closed date params[:dttm]
  put 'api/lead/:id/closed_date' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      lu = LeadUser.first(:lead_id => params[:id], :user_id => user.id)
      lu.closed_date = params[:dttm]
      if lu.valid?
        lu.save
        ret = {:success => 1}
        status 200
      else
        status 400
        ret = {:success => 0, :errors => lu.errors.to_hash}
      end
    end

    ret.to_json
  end

  # update status in lead_user table
  put 'api/lead/:id/status' do
    #params[:status]
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      lu = user.leadUsers.first(:lead_id => params[:id])
      lu.status = params[:status]
      if lu.valid?
        lu.save
        ret = {:success => 1}
        status 200
      else
        ret = {:success => 0, :errors => lu.errors.to_hash}
        status 400
      end
    end

    ret.to_json
  end

  # update source in lead_user table, params[:source]
  put 'api/lead/:id/source' do
    #params[:source] - id
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      lu = user.leadUsers.first(:lead_id => params[:id])
      lu.leadSource_id = params[:source_id]
      if lu.valid?
        lu.save
        ret = {:success => 1}
        status 200
      else
        ret = {:success => 0, :errors => lu.errors.to_hash}
        status 400
      end
    end

    ret.to_json
  end

  # update reference in lead
  put 'api/lead/:id/reference' do
    #params[:reference] - text
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      l = user.leads.first(:id => params[:id])
      l.reference = params[:reference]
      if l.valid?
        l.save
        ret = {:success => 1}
        status 200
      else
        ret = {:success => 0, :errors => l.errors.to_hash}
        status 400
      end
    end

    ret.to_json
  end

  # update address of a lead
  # params[:address], params[:city], params[:state], params[:zip] - text
  put 'api/lead/:id/address' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      l = user.leads.first(:id => params[:id])
      l.prop_address = params[:address]
      l.prop_city = params[:city]
      l.prop_state = params[:state]
      l.prop_zip = params[:zip]
      if l.valid?
        l.save
        ret = {:success => 1}
        status 200
      else
        ret = {:success => 0, :errors => l.errors.to_hash}
        status 400
      end
    end

    ret.to_json
  end

  # set contacted for lead. update :contacted & contacted & contact_date in lead_user table
  get 'api/lead/:id/set_contacted' do
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      lu = user.leadUsers.first(:lead_id => params[:id])
      lu.contacted = true
      lu.contact_date = Time.now
      if lu.valid?
        lu.save
        ret = {:success => 1}
        status 200
      else
        ret = {:success => 0, :errors => l.errors.to_hash}
        status 400
      end
    end

    ret.to_json
  end

  # update lead type for lead
  put 'api/lead/:id/lead_type' do
    # params[:lead_type_id] - Delete all lead stage data for this lead type
    # update the lead_type for that lead in lead_user
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      lu = user.leadUsers.first(:lead_id => params[:id])
      lu.lead.stageDates.all.destroy
      lt = LeadType.get(params[:lead_type_id])
      lu.leadType = lt
      if lu.valid?
        lu.save
        ret = lt.leadStages.all
        status 200
      else
        ret = {:success => 0, :errors => lu.errors.to_hash}
        status 400
      end
    end

    ret.to_json
  end

  # insert stage in stage_date
  post 'api/lead/:id/stage' do
    # params[:stage_id], params[:dttm]
    user_key = env['HTTP_AUTH_KEY']
    user = User.first(:user_key => user_key)
    if user.nil?
      ret = {:success => 0, :errors => ['Invalid User']}
      status 404
    else
      l = user.leads.first(:id => params[:id])
      sd = StageDate.new({:leadStage_id => params[:stage_id], :dttm => params[:dttm]})
      l.stageDates << sd
      if l.valid?
        l.stageDates.save
        ret = {:id => sd.id}
      else
        ret = {:success => 0, :errors => l.errors.to_hash}
        status 400
      end
    end

    ret.to_json
  end

end
