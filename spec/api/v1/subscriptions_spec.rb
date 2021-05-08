require "rails_helper"

resource "Subscriptions" do
  include_context "with Authorization header"

  let(:current_user) { create :user, email: "john.smith@example.com", full_name: "John Smith" }

  get "/v1/subscriptions" do
    let(:user) { create :user }
    let(:article) { create :article }
    let!(:subscription1) { create :subscription, user: current_user, entity: user }
    let!(:subscription2) { create :subscription, user: current_user, entity: article }
    let!(:subscription3) { create :subscription, entity: user }
    let(:expected_data) do
      [
        {
          "id" => subscription1.id,
          "entity_id" => subscription1.entity_id,
          "entity_type" => subscription1.entity_type,
          "user_id" => subscription1.user_id,
          "created_at" => subscription1.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        },
        {
          "id" => subscription2.id,
          "entity_id" => subscription2.entity_id,
          "entity_type" => subscription2.entity_type,
          "user_id" => subscription2.user_id,
          "created_at" => subscription2.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        }
      ]
    end

    it_behaves_like "API endpoint with authorization"

    example_request "List current user`s subscriptions" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end
  end

  get "/v1/subscriptions/:id" do
    parameter :id, "subscription id", required: true

    let(:article) { create :article }
    let!(:subscription) { create :subscription, user: current_user, entity: article }

    let(:id) { subscription.id }

    let(:expected_data) do
      {
        "id" => subscription.id,
        "entity_id" => subscription.entity_id,
        "entity_type" => subscription.entity_type,
        "user_id" => subscription.user_id,
        "created_at" => subscription.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Get Subscription" do
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

      example "Get Subscription with invalid id", document: false do
        do_request

        expect(response_status).to eq(404)
        expect(json_response_body).to eq(expected_data)
      end
    end
  end

  post "/v1/subscriptions" do
    parameter :article_id, "article id", required: false
    parameter :user_id, "user id (if you creates subscription to user)", required: false

    let(:article_id) { article.id }
    let(:article) { create :article }

    let(:created_subscription) { Subscription.last }

    let(:expected_data) do
      {
        "id" => created_subscription.id,
        "entity_id" => created_subscription.entity_id,
        "entity_type" => created_subscription.entity_type,
        "user_id" => created_subscription.user_id,
        "created_at" => created_subscription.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Create Subscription" do
      expect(response_status).to eq(201)
      expect(json_response_body).to eq(expected_data)
    end
  end

  delete "/v1/subscriptions/:id" do
    parameter :id, "like id", required: true

    let(:user) { create :user }
    let(:article) { create :article }

    let!(:subscription1) { create :subscription, user: current_user, entity: user }
    let!(:subscription2) { create :subscription, user: current_user, entity: article }
    let!(:subscription3) { create :subscription, user: current_user, entity: user }

    let(:id) { subscription3.id }

    let(:expected_data) do
      [
        {
          "id" => subscription1.id,
          "entity_id" => subscription1.entity_id,
          "entity_type" => subscription1.entity_type,
          "user_id" => subscription1.user_id,
          "created_at" => subscription1.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        },
        {
          "id" => subscription2.id,
          "entity_id" => subscription2.entity_id,
          "entity_type" => subscription2.entity_type,
          "user_id" => subscription2.user_id,
          "created_at" => subscription2.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        }
      ]
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Delete Subscription" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end
  end
end
