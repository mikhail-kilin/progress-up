require "rails_helper"

resource "Progress Informations" do
  include_context "with Authorization header"

  let(:current_user) { create :user, email: "john.smith@example.com", full_name: "John Smith" }

  let!(:article1) { create :article }
  let!(:article2) { create :article }

  get "/v1/subscribed_progress_informations" do
    parameter :article_id, "article id", required: true

    let!(:progress_information1) { create :progress_information, article: article1 }
    let!(:progress_information2) { create :progress_information, article: article2 }
    let!(:progress_information3) { create :progress_information }

    let!(:subscription1) { create :subscription, user: current_user, entity: article1 }
    let!(:subscription2) { create :subscription, user: current_user, entity: article2.user }

    let(:expected_data) do
      [
        {
          "id" => progress_information1.id,
          "content" => progress_information1.content,
          "amount" => progress_information1.amount,
          "article_id" => article1.id,
          "created_at" => progress_information1.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        },
        {
          "id" => progress_information2.id,
          "content" => progress_information2.content,
          "amount" => progress_information2.amount,
          "article_id" => article2.id,
          "created_at" => progress_information2.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        }
      ]
    end

    it_behaves_like "API endpoint with authorization"

    example_request "List Progress Informations by Subscriptions" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end
  end
end
