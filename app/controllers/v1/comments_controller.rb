module V1
  class CommentsController < V1::BaseController
    expose :comment
    expose :article, -> { Article.find_by(id: params[:article_id]) }

    def index
      respond_with article.comments.order(:created_at)
    end

    def show
      respond_with comment
    end

    def create
      comment.save

      respond_with comment
    end

    def update
      respond_with_error(:unauthorized) and return if comment.user != current_user
      comment.update(comment_params)

      respond_with comment
    end

    private

    def comment_params
      params.require(:comment).permit(:article_id, :content).merge(
        user_id: current_user.id
      )
    end
  end
end
