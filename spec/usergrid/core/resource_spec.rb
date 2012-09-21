describe Usergrid::Resource do

  before :all do
    @resource = Usergrid::Resource.new SPEC_SETTINGS[:api_url]
  end

  it "should succeed on status check" do
    response = @resource['/status'].get

    response.code.should eq 200
    response.data.should be_a Hash
  end

  it "should fail with a 400 when no auth given" do
    expect { @resource['management'].get }.to raise_error(RestClient::BadRequest) { |exception|
      exception.response.code.should eq 400
    }
  end

  it "should fail with a 401 when lacking auth" do
    expect { @resource[app_endpoint].get }.to raise_error(RestClient::Unauthorized) { |exception|
      exception.response.code.should eq 401
    }
  end

  it "should be able to login" do
    resource = @resource['management']
    response = resource.login SPEC_SETTINGS[:management][:username], SPEC_SETTINGS[:management][:password]

    response.code.should eq 200
    resource.auth_token.should_not be_nil
    response.data['access_token'].should eq resource.auth_token
    resource.options[:headers][:Authorization].should eq "Bearer #{resource.auth_token}"
    resource.logged_in?.should be_true
  end

  it "should be able to log out" do
    resource = @resource['management']
    resource.login SPEC_SETTINGS[:management][:username], SPEC_SETTINGS[:management][:password]
    resource.logged_in?.should be_true

    resource.logout
    resource.options[:headers][:Authorization].should be_nil
    resource.logged_in?.should be_false
  end

end