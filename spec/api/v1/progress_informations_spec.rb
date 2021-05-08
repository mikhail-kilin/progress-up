require "rails_helper"

resource "Progress Informations" do
  include_context "with Authorization header"

  let(:current_user) { create :user, email: "john.smith@example.com", full_name: "John Smith" }

  let!(:article) { create :article, user: current_user }
  let(:article_id) { article.id }

  get "/v1/progress_informations" do
    parameter :article_id, "article id", required: true

    let!(:progress_information1) { create :progress_information, article: article }
    let!(:progress_information2) { create :progress_information, article: article }
    let!(:progress_information3) { create :progress_information }

    let(:expected_data) do
      [
        {
          "id" => progress_information1.id,
          "content" => progress_information1.content,
          "amount" => progress_information1.amount,
          "article_id" => article_id,
          "created_at" => progress_information1.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        },
        {
          "id" => progress_information2.id,
          "content" => progress_information2.content,
          "amount" => progress_information2.amount,
          "article_id" => article_id,
          "created_at" => progress_information2.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
        }
      ]
    end

    it_behaves_like "API endpoint with authorization"

    example_request "List Progress Informations of Article" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end
  end

  get "/v1/progress_informations/:id" do
    parameter :id, "progress information id", required: true

    let!(:progress_information) { create :progress_information, article: article }

    let(:id) { progress_information.id }

    let(:expected_data) do
      {
        "id" => progress_information.id,
        "content" => progress_information.content,
        "amount" => progress_information.amount,
        "article_id" => article_id,
        "created_at" => progress_information.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Get Progress Information" do
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

      example "Get Progress Information with invalid id", document: false do
        do_request

        expect(response_status).to eq(404)
        expect(json_response_body).to eq(expected_data)
      end
    end
  end

  post "/v1/progress_informations" do
    with_options scope: :progress_information do
      parameter :article_id, "article id", required: true
      parameter :content, "content", required: true
      parameter :amount, "amount", required: false
    end

    let(:content) { "Content" }
    let(:amount) { 15_000 }
    let(:created_progress_information) { ProgressInformation.last }

    let(:expected_data) do
      {
        "id" => created_progress_information.id,
        "article_id" => article_id,
        "content" => created_progress_information.content,
        "amount" => created_progress_information.amount,
        "created_at" => created_progress_information.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Create Progress Information" do
      expect(response_status).to eq(201)
      expect(json_response_body).to eq(expected_data)
    end
  end

  patch "/v1/progress_informations/:id" do
    parameter :id, "progress informations id", required: true

    with_options scope: :progress_information do
      parameter :content, "content", required: true
      parameter :amount, "amount", required: false
    end

    let(:content) { "Content" }
    let(:amount) { 15_000 }
    let(:id) { progress_information.id }
    let(:progress_information) { create :progress_information, article: article }

    let(:expected_data) do
      {
        "id" => progress_information.reload.id,
        "article_id" => article_id,
        "content" => progress_information.content,
        "amount" => progress_information.amount,
        "created_at" => progress_information.created_at.to_json.chomp('"').gsub(/\A"|"\Z/, "")
      }
    end

    it_behaves_like "API endpoint with authorization"

    example_request "Updates Progress Information" do
      expect(response_status).to eq(200)
      expect(json_response_body).to eq(expected_data)
    end

    context "when unauthorized" do
      let(:content) { "Content" }
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

      example "Update Progress Information with another owner", document: false do
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

      example "Update Progress Information with empty title and content", document: false do
        do_request

        expect(response_status).to eq(422)
        expect(json_response_body).to eq(expected_data)
      end
    end
  end
end
