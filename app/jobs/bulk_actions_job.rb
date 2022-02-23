class BulkActionsJob < ApplicationJob
  queue_as :medium
  attr_accessor :records

  MODEL_TYPE = ['Conversation'].freeze

  def perform(account:, params:, user:)
    @account = account
    Current.user = user
    @params = params
    @records = records_to_updated(params[:ids])
    bulk_update
  rescue StandardError => e
    Current.reset
    Sentry.capture_exception(e)
  end

  def bulk_update
    bulk_remove_labels
    bulk_conversation_update
    unset_current_user
  end

  def bulk_conversation_update
    params = available_params(@params)
    records.each do |conversation|
      bulk_add_labels(conversation)
      conversation.update(params) if params
    end
  end

  def bulk_remove_labels
    records.each do |conversation|
      remove_labels(conversation)
    end
  end

  def available_params(params)
    return unless params[:fields]

    params[:fields].delete_if { |_k, v| v.nil? }
  end

  def bulk_add_labels(conversation)
    conversation.add_labels(@params[:labels][:add]) if @params[:labels] && @params[:labels][:add]
  end

  def remove_labels(conversation)
    return unless @params[:labels] && @params[:labels][:remove]

    labels = conversation.label_list - @params[:labels][:remove]
    conversation.update(label_list: labels)
  end

  def records_to_updated(ids)
    current_model = @params[:type].camelcase
    return unless MODEL_TYPE.include?(current_model)

    current_model.constantize&.where(account_id: @account.id, display_id: ids)
  end

  def unset_current_user
    Current.reset
  end
end
