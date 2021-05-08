module V1
  class ProgressInformationsController < V1::BaseController
    expose :progress_information
    expose :article, -> { Article.find_by(id: params[:article_id]) }

    def index
      respond_with article.progress_informations.order(:created_at)
    end

    def show
      respond_with progress_information
    end

    def create
      progress_information.save

      respond_with progress_information
    end

    def update
      respond_with_error(:unauthorized) and return if progress_information.article.user != current_user
      progress_information.update(progress_information_params)

      respond_with progress_information
    end

    private

    def progress_information_params
      params.require(:progress_information).permit(:article_id, :content, :amount)
    end
  end
end
