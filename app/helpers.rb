# Helper methods defined here can be accessed in any controller or view in the application

Leadtraker.helpers do

  	def get_formatted_errors(errors)

		err_list = Array.new()
		  	errors.each do |e|
			err_list.push(e.pop)
	  	end

  		return err_list

	end

	def is_lender?(user)

		return user.type == 2
		
	end
	
end
