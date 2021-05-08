module V1
  class SubscriptionsController < V1::BaseController
    expose :subscription
    expose :subscriptions, -> { current_user.subscriptions.order(:created_at) }

    def index
      respond_with subscriptions
    end

    def show
      respond_with subscription
    end

    def create
      subscription.save

      respond_with subscription
    end

    def update
      respond_with_error(:unauthorized) and return if subscription.user != current_user
      subscription.update(subscription_params)

      respond_with subscription
    end

    def destroy
      respond_with_error(:unauthorized) and return if subscription.user != current_user
      subscription.destroy

      respond_with subscriptions
    end

    private

    def subscription_params
      {
        user_id: current_user.id,
        entity: entity
      }
    end

    def entity
      article || user
    end

    def article
      Article.find_by(id: params[:article_id])
    end

    def user
      User.find_by(id: params[:user_id])
    end
  end
end
