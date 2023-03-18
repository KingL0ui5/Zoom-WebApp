require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  it "Success: renders the home page of the application" do
    get :index
    expect(response).to render_template("index")
  end
  
  it "Success: renders the users/new page" do
    get :new
    expect(response).to render_template("new")#
  end
  
  
end

