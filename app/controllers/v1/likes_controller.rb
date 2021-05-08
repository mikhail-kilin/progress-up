module V1
  class LikesController < V1::BaseController
    expose :like
    expose :article, -> { find_article }

    def index
      respond_with article.likes.order(:created_at)
    end

    def create
      respond_with_error(:invalid_record) and return if Like.find_by(like_params).present?
      like.save

      respond_with like
    end

    def destroy
      article
      respond_with_error(:unauthorized) and return if like.user != current_user
      like.destroy if like.present?

      respond_with article.likes.order(:created_at)
    end

    private

    def like_params
      params.require(:like).permit(:article_id).merge(
        user_id: current_user.id
      )
    end

    def find_article
      @find_article ||= Article.find_by(id: params[:article_id])
    end
  end
end
