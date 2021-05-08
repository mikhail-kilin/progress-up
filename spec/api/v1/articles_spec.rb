require "rails_helper"

resource "Articles" do
  include_context "with Authorization header"

  let(:current_user) { create :user, email: "john.smith@example.com", full_name: "John Smith" }

  let!(:article1) { create :article }
  let!(:article2) { create :article }

  get "/v1/articles" do
    let(:expected_data) do
      [
        {
          "id" => article1.id,
          "title" => article1.title,
          "content" => article1.content,
          "user_id" => article1.user_id,
          "created_at" => article1.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        },
        {
          "id" => article2.id,
          "title" => article2.title,
          "content" => article2.content,
          "user_id" => article2.user_id,
          "created_at" => article2.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        }
      ]
    end

    it_behaves_like "API endpoint with authorization"

    example_request "List Articles" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end
  end

  get "/v1/articles/:id" do
    parameter :id, "article id", required: true

    let(:id) { article1.id }

    let(:expected_data) do
      {
        "id" => article1.id,
        "title" => article1.title,
        "content" => article1.content,
        "user_id" => article1.user_id,
        "created_at" => article1.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Get Article" do
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

      example "Get Article with invalid id", document: false do
        do_request

        expect(response_status).to eq(404)
        expect(json_response_body).to eq(expected_data)
      end
    end
  end

  post "/v1/articles" do
    with_options scope: :article do
      parameter :title, "title", required: true
      parameter :content, "content", required: true
    end

    let(:title) { "Title" }
    let(:content) { "Content" }
    let(:created_article) { Article.last }

    let(:expected_data) do
      {
        "id" => created_article.id,
        "title" => created_article.title,
        "content" => created_article.content,
        "user_id" => created_article.user_id,
        "created_at" => created_article.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Create Article" do
      expect(response_status).to eq(201)
      expect(json_response_body).to eq(expected_data)
    end
  end

  patch "/v1/articles/:id" do
    parameter :id, "article id", required: true

    with_options scope: :article do
      parameter :title, "title", required: true
      parameter :content, "content", required: true
    end

    let(:id) { article.id }
    let(:title) { "Title" }
    let(:content) { "Content" }
    let(:article) { create :article, user: current_user }

    let(:expected_data) do
      {
        "id" => article.reload.id,
        "title" => article.title,
        "content" => article.content,
        "user_id" => article.user_id,
        "created_at" => article.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Updates Article" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end

    context "when unauthorized" do
      let(:content) { "Content" }
      let(:title) { "Title" }
      let(:article) { create :article }

      let(:expected_data) do
        {
          "errors" => [
            {
              "error" => "Authorization required",
              "id" => "4eac02e2-6856-449b-bc28-fbf1b32a20f2",
              "status" => 401
            }
          ]
        }
      end

      example "Update Article with another owner", document: false do
        do_request

        expect(response_status).to eq(401)
        expect(json_response_body).to eq(expected_data)
      end
    end

    context "with invalid data" do
      let(:content) { "" }
      let(:title) { nil }

      let(:expected_data) do
        {
          "error" => "Invalid record",
          "id" => "4eac02e2-6856-449b-bc28-fbf1b32a20f2",
          "status" => 422,
          "validations" => {
            "content" => ["can't be blank"],
            "title" => ["can't be blank"]
          }
        }
      end

      example "Update Article with empty title and content", document: false do
        do_request

        expect(response_status).to eq(422)
        expect(json_response_body).to eq(expected_data)
      end
    end
  end
end
