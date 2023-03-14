require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  it "renders the home page of the application" do
    get :index
    expect(response).to render_template("index")
  end
end

RSpec.describe "users/index.html.erb", type: :view do
  it "displays a list of users" do
    assign(:users, [User.new(Name: "Alice"), User.new(Name: "Bob")])
    render
    expect(rendered).to have_content("Alice")
    expect(rendered).to have_content("Bob")
  end
end