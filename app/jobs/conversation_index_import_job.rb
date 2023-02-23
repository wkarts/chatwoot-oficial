class ConversationIndexImportJob < ApplicationJob
  queue_as :low

  def perform
    bulk_records
  end

  def self.prepare_records(conversations)
    conversations.map do |conversation|
      { index: { _id: conversation.id, data: conversation.as_indexed_json } }
    end
  end

  def bulk_records
    Conversation.includes(:contact).find_in_batches do |conversations|
      bulk_index(conversations)
    end
  end

  def self.bulk_index(conversations)
    Conversation.__elasticsearch__.client.bulk({
                                                 index: ::Conversation.__elasticsearch__.index_name,
                                                 type: ::Conversation.__elasticsearch__.document_type,
                                                 body: prepare_records(conversations)
                                               })
  end
end
