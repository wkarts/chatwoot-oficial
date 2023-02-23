class AddElasticSearchIndexes < ActiveRecord::Migration[6.1]
  def up
    Conversation.__elasticsearch__.create_index! force: true
    Message.__elasticsearch__.create_index! force: true

    ## Import data to index via background jobs
    ConversationImportJob.perform_later
    MessageIndexImportJob.perform_later
  end

  def down
    Conversation.__elasticsearch__.delete_index!
    Message.__elasticsearch__.delete_index!
  end
end
