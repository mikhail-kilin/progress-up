require "rails_helper"

resource "Users" do
  include_context "with Authorization header"

  get "/v1/users" do
    let!(:user_1) { create :user, full_name: "Michael Jordan", email: "michael.jordan@example.com" }
    let!(:user_2) { create :user, full_name: "Brad Pitt", email: "brad.pitt@example.com" }
    let!(:user_3) { create :user, full_name: "Steve Jobs", email: "steve.jobs@example.com" }

    let(:expected_data) do
      [
        {
          "id" => user_1.id,
          "email" => "michael.jordan@example.com",
          "full_name" => "Michael Jordan",
          "avatar_url" => user_1.avatar_url,
          "description" => user_1.description,
          "phone" => user_1.phone
        },
        {
          "id" => user_2.id,
          "email" => "brad.pitt@example.com",
          "full_name" => "Brad Pitt",
          "avatar_url" => user_2.avatar_url,
          "description" => user_2.description,
          "phone" => user_2.phone
        },
        {
          "id" => user_3.id,
          "email" => "steve.jobs@example.com",
          "full_name" => "Steve Jobs",
          "avatar_url" => user_3.avatar_url,
          "description" => user_3.description,
          "phone" => user_3.phone
        },
        {
          "id" => current_user.id,
          "email" => current_user.email,
          "full_name" => current_user.full_name,
          "avatar_url" => current_user.avatar_url,
          "description" => current_user.description,
          "phone" => current_user.phone
        }
      ]
    end

    it_behaves_like "API endpoint with authorization"

    example_request "List Users" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end
  end

  get "/v1/users/:id" do
    parameter :id, "user id", required: true

    let(:user) { create :user, full_name: "John Smith", email: "john.smith@example.com" }
    let(:id) { user.id }

    let(:expected_data) do
      {
        "id" => user.id,
        "email" => "john.smith@example.com",
        "full_name" => "John Smith",
        "avatar_url" => user.avatar_url,
        "description" => user.description,
        "phone" => user.phone
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Retrieve User" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end

    context "with invalid id" do
      let(:id) { 0 }
      let(:expected_data) do
        {
          "errors" => [
            {
              "id" => "4eac02e2-6856-449b-bc28-fbf1b32a20f2",
              "status" => 404,
              "error" => "Record not found"
            }
          ]
        }
      end

      example "Retrieve User with invalid id", document: false do
        do_request

        expect(response_status).to eq(404)
        expect(json_response_body).to eq(expected_data)
      end
    end
  end
end
