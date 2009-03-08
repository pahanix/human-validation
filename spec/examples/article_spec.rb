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
    @article.errors.full_messages.should == ["Please fill Title and Permalink fields"]
  end
end