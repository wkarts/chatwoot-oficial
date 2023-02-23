class MessageIndexImportJob < ApplicationJob
  queue_as :low

  def perform
    bulk_records
  end

  def self.prepare_records(messages)
    messages.map do |message|
      { index: { _id: message.id, data: message.as_indexed_json } }
    end
  end

  def bulk_records
    Message.find_in_batches do |messages|
      bulk_index(messages)
    end
  end

  def self.bulk_index(messages)
    Message.__elasticsearch__.client.bulk({
                                            index: ::Message.__elasticsearch__.index_name,
                                            type: ::Message.__elasticsearch__.document_type,
                                            body: prepare_records(messages)
                                          })
  end
end
