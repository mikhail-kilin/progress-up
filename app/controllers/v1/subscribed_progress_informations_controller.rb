module V1
  class SubscribedProgressInformationsController < V1::BaseController
    def index
      respond_with ProgressInformation.where(id: progress_information_ids).order(:created_at)
    end

    private

    def articles
      @articles ||= (subscribed_articles + subscribed_articles_from_users).uniq
    end

    def subscribed_articles
      current_user.subscriptions.where(entity_type: "Article").map(&:entity)
    end

    def subscribed_articles_from_users
      result = []

      subscribed_users.each do |user|
        result += user.articles.to_a
      end

      result
    end

    def subscribed_users
      current_user.subscriptions.where(entity_type: "User").map(&:entity)
    end

    def progress_information_ids
      result = []

      articles.each do |article|
        result += article.progress_information_ids
      end

      result
    end
  end
end
