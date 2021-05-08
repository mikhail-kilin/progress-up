require "rails_helper"

resource "Likes" do
  include_context "with Authorization header"

  let(:current_user) { create :user, email: "john.smith@example.com", full_name: "John Smith" }

  let!(:article) { create :article }
  let(:article_id) { article.id }

  get "/v1/likes" do
    parameter :article_id, "article id", required: true

    let!(:like1) { create :like, article: article }
    let!(:like2) { create :like, article: article }
    let!(:like3) { create :like }

    let(:expected_data) do
      [
        {
          "id" => like1.id,
          "user_id" => like1.user_id,
          "article_id" => article_id,
          "created_at" => like1.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        },
        {
          "id" => like2.id,
          "user_id" => like2.user_id,
          "article_id" => article_id,
          "created_at" => like2.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        }
      ]
    end

    it_behaves_like "API endpoint with authorization"

    example_request "List Likes of Article" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end
  end

  post "/v1/likes" do
    with_options scope: :like do
      parameter :article_id, "article id", required: true
    end

    let(:created_like) { Like.last }

    let(:expected_data) do
      {
        "id" => created_like.id,
        "article_id" => article_id,
        "user_id" => created_like.user_id,
        "created_at" => created_like.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Create Like" do
      expect(response_status).to eq(201)
      expect(json_response_body).to eq(expected_data)
    end

    context "when you have Like" do
      let!(:like) { create :like, user: current_user, article: article }
      let(:expected_data) do
        {
          "errors" => [
            {
              "id" => "4eac02e2-6856-449b-bc28-fbf1b32a20f2",
              "status" => 422,
              "error" => "Invalid record"
            }
          ]
        }
      end

      example "Get Like with invalid id", document: false do
        do_request

        expect(response_status).to eq(422)
        expect(json_response_body).to eq(expected_data)
      end
    end
  end

  delete "/v1/likes/:id" do
    parameter :id, "like id", required: true
    parameter :article_id, "article id", required: true

    let!(:like1) { create :like, article: article, user: current_user }
    let!(:like2) { create :like, article: article, user: current_user }
    let!(:like3) { create :like, article: article, user: current_user }

    let(:id) { like3.id }

    let(:expected_data) do
      [
        {
          "id" => like1.id,
          "user_id" => like1.user_id,
          "article_id" => article_id,
          "created_at" => like1.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        },
        {
          "id" => like2.id,
          "user_id" => like2.user_id,
          "article_id" => article_id,
          "created_at" => like2.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        }
      ]
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Delete Like" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end
  end
end
