require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Symbol do

  describe "#extract" do
    it "should extract [self, {}]" do
      :login.extract.should == [:login, {}]
    end
  end
  
  describe "#as" do
    it "should return [self, {:as => \"Country\"}] after extracting" do
      :country.as("Country").extract.should == [:country, {:as => "Country"}] 
      :country.as("AAA").as("Country").extract.should == [:country, {:as => "Country"}]   
    end
    
    it "should be like symbol" do
      :country.as("Country").should be_instance_of(SymbolProxy);
      :country.as("Country").to_sym.should == :country;
    end
  end  
  
  describe "#case_sensitive" do
    it "should return [:uniq, {:case_sensitive => true}] for :uniq symbol" do
      :uniq.case_sensitive.should be_instance_of(SymbolProxy);
      :uniq.case_sensitive.extract.should == [:uniq, { :case_sensitive => true }]
    end

    it "should add message to options and return [:uniq, {:case_sensitive => true, :message => \"Message\"}]" do
      :uniq.case_sensitive("Message").extract.should == [:uniq, { :case_sensitive => true, :message => "Message" }]
    end
    
    it "should add message to options and return [:uniq, { :message => \"Message\"}]" do
      :uniq.message("Message").extract.should == [:uniq, { :message => "Message" }]
    end
    
    it "should raise NoMethodError for :any_sym.case_sensitive" do
      lambda { :format.case_sensitive }.should raise_error(NoMethodError, /\:format/)
    end
  end


  describe "#scope" do
    it "should return [:uniq, {:scope => +scope+}] for :uniq symbol" do
      :uniq.scope(:account).should be_instance_of(SymbolProxy);
      :uniq.scope(:account).extract.should == [:uniq, { :scope => :account }]
    end
    
    it "should return [:uniq, {:scope => [+scopes+]}] for :uniq symbol" do
      :uniq.scope(:room, :teacher).extract.should == [:uniq, { :scope => [:room, :teacher]}]      
    end

    it "should correctly add args and message to options" do
      :uniq.scope(:room, :teacher, "Message").extract.should == [:uniq, { :scope => [:room, :teacher], :message => "Message" }]
    end
    
    it "should add message to options" do
      :uniq.scope("Message").extract.should == [:uniq, { :message => "Message" }]
    end
    
    it "should raise NoMethodError for :any_other_sym.scope" do
      lambda { :format.scope(:email) }.should raise_error(NoMethodError, /\:format/)
    end
  end


  # :length.in, :length.is(), :length.min, :lenght.max, :length.within

  describe "#in for :length" do
    it "should return [:length, {:in => +range+}] for :length symbol" do
      :length.in(1..100).should be_instance_of(SymbolProxy);
      :length.in(1..100).extract.should == [:length, { :in => 1..100 }]
    end

    it "should correctly add args and message to options" do
      :length.in(1..100, "Message").extract.should == [:length, { :in => 1..100, :message => "Message" }]
    end
       
    it "should raise ArgumentError for :length.in(+not_range+)" do
      lambda { :length.in("str") }.should raise_error(ArgumentError, /\:length/)
      lambda { :length.in(500) }.should raise_error(ArgumentError, /\:length/)      
    end   
        
    it "should raise NoMethodError for :any_other_sym.in" do
      lambda { :unknown.in(1..100) }.should raise_error(NoMethodError, /\:unknown/)
    end
  end


  describe "#min(max) for :length" do
    it "should return [:length, {:min => +num+}] for :length symbol" do
      :length.min(5).should be_instance_of(SymbolProxy);
      :length.min(5).extract.should == [:length, { :minimum => 5 }]
    end
    
    it "should return [:length, {:max => +num+}] for :length symbol" do
      :length.max(30).should be_instance_of(SymbolProxy);
      :length.max(30).extract.should == [:length, { :maximum => 30 }]
    end
    
    it "should correctly add minimum and too_short message to options" do
      :length.min(5, "Min message").extract.should == [:length, { :minimum => 5, :too_short => "Min message" }]
    end

    it "should correctly add maximum and to_long message to options" do
      :length.max(30, "Max message").extract.should == [:length, { :maximum => 30, :too_long => "Max message" }]
    end
        
    it "should raise NoMethodError for :any_other_sym.min" do
      lambda { :unknown.min(10) }.should raise_error(NoMethodError, /\:unknown/)
      lambda { :unknown.man(30) }.should raise_error(NoMethodError, /\:unknown/)      
    end
  end


  describe "#within for :length" do
    it "should return [:length, {:within => +range+}] for :length symbol" do
      :length.within(5..50).should be_instance_of(SymbolProxy);
      :length.within(5..50).extract.should == [:length, { :within => 5..50 }]
    end
        
    it "should correctly add within and too_short message to options" do
      :length.within(5..50, "Min message").extract.should == [:length, { :within => 5..50, :too_short => "Min message" }]
    end
  
    it "should correctly add within, too_short and to_long message to options" do
      :length.within(5..50, "Min message", "Max message").extract.should == [:length, { :within => 5..50, :too_short => "Min message", :too_long => "Max message" }]
    end

    it "should correctly add within too_short and too_long message as hash to options" do
      :length.within(5..50, :too_short => "Min message", :too_long => "Max message").extract.should == [:length, { :within => 5..50, :too_short => "Min message", :too_long => "Max message" }]
    end

    it "should correctly add within and too_short to options" do
      :length.within(5..50, :too_short => "Min message").extract.should == [:length, { :within => 5..50, :too_short => "Min message" }]
    end

    it "should correctly add within and too_long to options" do
      :length.within(5..50, :too_long => "Max message").extract.should == [:length, { :within => 5..50, :too_long => "Max message" }]
    end
        
    it "should raise NoMethodError for :any_other_sym.within" do
      lambda { :unknown.within(1..100) }.should raise_error(NoMethodError, /\:unknown/)
    end

    it "should raise ArgumentError for :length.within()" do
      lambda { :length.within() }.should raise_error(ArgumentError, /\:length/)
    end
    
    it "should raise TypeError for :length.within(+not_range+)" do
      lambda { :length.within("str") }.should raise_error(TypeError, /\:length/)
      lambda { :length.within(500) }.should raise_error(TypeError, /\:length/)      
    end   

  end


  describe "#is" do
    it "should return [self, {:is => [[:uniq, {}] }] after extracting" do
      :country.as("Country").should be_instance_of(SymbolProxy);
      :country.is(:uniq).extract.should == [:country, {:is => [ [:uniq, {}] ] }] 
    end

    it "should extract right way" do
      :country.is(:uniq.case_sensitive, :length.in(5..6), :format).extract.should == 
        [:country, 
          {
            :is => [
              [:uniq, { :case_sensitive => true }],
              [:length, { :in => 5..6 }],
              [:format, {}]
            ] 
          }
        ] 
    end

    it "should extract right way for :length(+fixnum+)" do
      :length.is(5).extract.should == [:length, {:is => 5}] 
    end    

    it "should extract right way for nested :length(+fixnum+)" do
      :country.is(:length.is(5)).extract.should == [:country, { :is => [ [:length, {:is => 5}] ] }] 
      :length.is(:length.is(5)).extract.should == [:length, { :is => [ [:length, {:is => 5}] ] }]       
    end    

  end
end