require "rails_helper"

resource "Comments" do
  include_context "with Authorization header"

  let(:current_user) { create :user, email: "john.smith@example.com", full_name: "John Smith" }

  let!(:article) { create :article }
  let(:article_id) { article.id }

  get "/v1/comments" do
    parameter :article_id, "article id", required: true

    let!(:comment1) { create :comment, article: article }
    let!(:comment2) { create :comment, article: article }
    let!(:comment3) { create :comment }

    let(:expected_data) do
      [
        {
          "id" => comment1.id,
          "content" => comment1.content,
          "user_id" => comment1.user_id,
          "article_id" => article_id,
          "created_at" => comment1.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        },
        {
          "id" => comment2.id,
          "content" => comment2.content,
          "user_id" => comment2.user_id,
          "article_id" => article_id,
          "created_at" => comment2.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        }
      ]
    end

    it_behaves_like "API endpoint with authorization"

    example_request "List Comments of Article" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end
  end

  get "/v1/comments/:id" do
    parameter :id, "comment id", required: true

    let!(:comment) { create :comment, article: article }

    let(:id) { comment.id }

    let(:expected_data) do
      {
        "id" => comment.id,
        "content" => comment.content,
        "user_id" => comment.user_id,
        "article_id" => article_id,
        "created_at" => comment.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Get Comment" do
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

      example "Get Comment with invalid id", document: false do
        do_request

        expect(response_status).to eq(404)
        expect(json_response_body).to eq(expected_data)
      end
    end
  end

  post "/v1/comments" do
    with_options scope: :comment do
      parameter :article_id, "article id", required: true
      parameter :content, "content", required: true
    end

    let(:content) { "Content" }
    let(:created_comment) { Comment.last }

    let(:expected_data) do
      {
        "id" => created_comment.id,
        "article_id" => article_id,
        "content" => created_comment.content,
        "user_id" => created_comment.user_id,
        "created_at" => created_comment.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Create Comment" do
      expect(response_status).to eq(201)
      expect(json_response_body).to eq(expected_data)
    end
  end

  patch "/v1/comments/:id" do
    parameter :id, "comment id", required: true

    with_options scope: :comment do
      parameter :content, "content", required: true
    end

    let(:content) { "Content" }
    let(:id) { comment.id }
    let(:comment) { create :comment, user: current_user, article: article }

    let(:expected_data) do
      {
        "id" => comment.reload.id,
        "article_id" => article_id,
        "content" => comment.content,
        "user_id" => comment.user_id,
        "created_at" => comment.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Updates Comment" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end

    context "when unauthorized" do
      let(:content) { "Content" }
      let(:comment) { create :comment }

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

      example "Update Comment with another owner", document: false do
        do_request

        expect(response_status).to eq(401)
        expect(json_response_body).to eq(expected_data)
      end
    end

    context "with invalid data" do
      let(:content) { "" }

      let(:expected_data) do
        {
          "error" => "Invalid record",
          "id" => "4eac02e2-6856-449b-bc28-fbf1b32a20f2",
          "status" => 422,
          "validations" => {
            "content" => ["can't be blank"]
          }
        }
      end

      example "Update Comment with empty title and content", document: false do
        do_request

        expect(response_status).to eq(422)
        expect(json_response_body).to eq(expected_data)
      end
    end
  end
end
