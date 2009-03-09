class Address < ActiveRecord::Base
  
  please_choose :country, :as => "your country"
  and_fill :city, :name, :zip, [:adress, "Home Adress"]
  and_make_sure :zip, :as => "Zip code", :is => [:uniq, :numeric, {:lenght => 5}, {:format => /^0\d{4}$/}]
  and_also_make_sure :phone, :is => :numeric

  otherwise "we can't bill you properly. Thank you!"
end


describe Address, "validation" do
  it "should provide 1 error message" do
    @address = Address.new
    @address.should_not be_valid
    @address.should have(1).errors_on(:base)    
    HumanValidation.render_error_messages(@article).should include("Please choose your country and fill City, Name, Zip code and Home Adress fields also please make sure that Zip code is uniq, numeric, more 5 characters long and Phone also is a number. Otherwise we can't bill you properly. Thank you!")
  end
end