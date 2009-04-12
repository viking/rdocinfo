require "#{File.dirname(__FILE__)}/spec_helper"

describe 'Project' do
  before(:each) do
    @project = Project.new(valid_attributes)
  end

  it 'should be valid' do
    @project.should be_valid
  end

  it 'should have a clone url' do
    @project.clone_url.should == 'git://github.com/zapnap/simplepay.git'
  end

  describe 'validations' do
    before(:each) do
      @project.stub!(:update_rdoc).and_return(true)
    end

    it 'should require a name' do
      @project.name = nil
      @project.should_not be_valid
      @project.errors[:name].should include("Name must not be blank")
    end

    it 'should require an owner' do
      @project.owner = nil
      @project.should_not be_valid
      @project.errors[:owner].should include("Owner must not be blank")
    end

    it 'should require a url' do
      @project.url = nil
      @project.should_not be_valid
      @project.errors[:url].should include("Url must not be blank")
    end

    it 'should require a unique url' do
      @project.save
      @project = Project.new(valid_attributes)
      @project.should_not be_valid
      @project.errors[:url].should include("Url is already taken")
    end
  end

  describe 'rdoc generation' do
    before(:each) do
      @rdoc_dir = File.expand_path(File.dirname(__FILE__) + '/spec/rdoc')
      @tmp_dir = File.expand_path(File.dirname(__FILE__) + '/spec/tmp')
      @project.stub!(:rdoc_dir).and_return(@rdoc_dir)
      @project.stub!(:clone_dir).and_return(@tmp_dir)
      FileUtils.rm_rf @rdoc_dir
      FileUtils.rm_rf @tmp_dir
    end

    it 'should place rdoc in public directory' do
      @project.update_rdoc
      File.exists?("#{@rdoc_dir}/index.html").should be_true
    end

    it 'should clean clone directory after build' do
      @project.update_rdoc
      File.exists?("#{@tmp_dir}}").should be_false
    end

    it 'should auto-generate after save' do
      @project.should_receive(:update_rdoc)
      @project.save
    end
  end

  private

  def valid_attributes
    { :name  => 'simplepay',
      :owner => 'zapnap',
      :url   => 'http://github.com/zapnap/simplepay' }
  end
end