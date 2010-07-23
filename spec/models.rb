# Just some ideas
# creates /users/:user_id => serialized user (json?)
class User < Toystore::Base
  attribute :name, String, :required => true
  
  # creates /users/ssn/:ssn => user_id
  attribute :ssn, String, :required => true, :unique => true
  
  # creates /users/birth_year/:year => [user_ids]
  attribute :birthday, Date, :indexed_as => 'birth_year', :indexed_by => :year
  
  # creates /users/favorite_number/:favorite_number => [user_ids]
  attribute :favorite_number, Integer, :indexed => true
  
  attribute :favorite_colors, Array
  attribute :other_details, Hash
  
  # serialized and stored in serialized user
  # /users/state/:state => [user_ids]
  attribute :mailing_address, Address, :indexed_by => :state
  attribute :other_addresses, Address, :multiple => true # serialized and stored in serialized user in array
  
  # /users/:user_id/phone_numbers => [serialized phone numbers]
  # /users/area_code/:area_code => [user_ids]
  list :phone_numbers, PhoneNumber, :indexed_by => :area_code

  # stored internally as company_id on user
  # /companies/:company_id/employees => [user_ids]
  reference :company, Company, :reverse_of => :employees

  # /users/:user_id/languages => [language_ids]  
  reference :languages, Language, :multiple => true
  
  timestamps
end

# creates /addresses/:address_id => serialized address
class Address < Toystore::Base
  attribute :street, String
  attribute :city, String, :required => true
  attribute :state, String, :required => true
  attribute :zip, String
end

# creates /phone_numbers/:phone_number_id => serialized phone number
class PhoneNumber < Toystore::Base
  attribute :area_code, String
  attribute :number, String
  attribute :type, String
end

# create /companies/:company_id => serialized company
class Company < Toystore::Base
  attribute :name, String, :required => true
  attribute :shipping_address, Address
  attribute :billing_address, Address
  
  list :contact_numbers, PhoneNumber
  
  # /companies/:company_id/employees => [user_ids]
  reference :employees, User, :mulitple => true
end

# create /languages/:language_id => serialized language
class Language < Toystore::Base
  attribute :name, String
end
