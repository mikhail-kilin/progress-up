require "rails_helper"

resource "Registration" do
  include_context "with API Headers"

  post "/v1/registrations" do
    with_options scope: :user do
      parameter :full_name, "full name"
      parameter :email, "email", required: true
      parameter :password, "password", required: true
      parameter :phone, "phone"
      parameter :description, "description"
      parameter :avatar, "avatar file"
    end

    let(:full_name) { "Example User" }
    let(:email) { "user@example.com" }
    let(:password) { "123456" }
    let(:phone) { "89999999999" }
    let(:description) { "description" }

    let(:expected_data) do
      {
        "id" => User.last.id,
        "email" => "user@example.com",
        "full_name" => "Example User",
        "avatar_url" => User.last.avatar_url,
        "description" => "description",
        "phone" => "89999999999"
      }
    end

    example_request "Create User" do
      expect(response_status).to eq(201)
      expect(json_response_body).to eq(expected_data)
    end
  end
end
