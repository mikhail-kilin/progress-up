module V1
  class ArticlesController < V1::BaseController
    expose :article
    expose :articles, -> { Article.all.order(:created_at) }

    def index
      respond_with articles
    end

    def show
      respond_with article
    end

    def create
      article.save

      respond_with article
    end

    def update
      respond_with_error(:unauthorized) and return if article.user != current_user
      article.update(article_params)

      respond_with article
    end

    private

    def article_params
      params.require(:article).permit(:title, :content).merge(
        user_id: current_user.id
      )
    end
  end
end
