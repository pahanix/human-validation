class Article < ActiveRecord::Base
  please_fill :title, :permalink
end

describe Article, "validation" do
  before do
    @article = Article.new
  end

  it "should provide error message 'Please fill Title and Permalink fields'" do
    @article.should_not be_valid
    @article.should have(1).errors_on(:human_error)
    HumanValidation.render_error_messages(@article).should == ["Please fill Title and Permalink fields"]
  end
end