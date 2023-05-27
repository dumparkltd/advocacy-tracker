class TaskNotificationJob
  include Sidekiq::Worker

  def perform(user_id, measure_id)
    user_measure = UserMeasure.find_by(user_id: user_id, measure_id: measure_id)
    return if !user_measure || !user_measure.notify?

    UserMeasureMailer.task_updated(user_measure).deliver_now
  end
end
