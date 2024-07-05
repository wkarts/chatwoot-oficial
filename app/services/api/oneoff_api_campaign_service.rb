class Api::OneoffApiCampaignService
  pattr_initialize [:campaign!]

  def perform
    raise "Invalid campaign #{campaign.id}" if campaign.inbox.inbox_type != 'API' || !campaign.one_off?
    raise 'Completed Campaign' if campaign.completed?

    # marks campaign completed so that other jobs won't pick it up
    campaign.completed!

    # Get id of labels
    audience_label_ids = campaign.audience.select { |audience| audience['type'] == 'Label' }.pluck('id')
    # Get all labels that contains label ids
    audience_labels = campaign.account.labels.where(id: audience_label_ids).pluck(:title)
    process_audience(audience_labels)
  end

  private

  delegate :inbox, to: :campaign
  delegate :channel, to: :inbox

  def process_audience(audience_labels)
    # get all contacts with labels
    campaign.account.contacts.tagged_with(audience_labels, any: true).each do |contact|
      next if contact.phone_number.blank?

      send_message(contact: contact, content: campaign.message)
    end
  end

  def build_conversation(contact:, contact_inbox:)
    conversation_params = {
      account_id: inbox.account_id,
      inbox_id: campaign.inbox_id,
      contact_id: contact.id,
      contact_inbox: contact_inbox
    }
    ::Conversation.create!(conversation_params)
  end

  def build_message(content:, conversation:)
    message_params = {
      conversation_id: conversation.id,
      account_id: inbox.account_id,
      inbox_id: campaign.inbox_id,
      content: content,
      private: false,
      message_type: 1,
      content_type: 0
    }
    ::Message.create!(message_params)
  end

  def build_contact_inbox(contact:)
    contact_inbox = ContactInbox.find_or_initialize_by(contact_id: contact.id, inbox_id: campaign.inbox_id)

    return contact_inbox if contact_inbox.persisted?

    ContactInboxBuilder.new(
      contact: contact,
      inbox: inbox,
      hmac_verified: false
    ).perform
    contact_inbox.reload
  end

  def send_message(contact:, content:)
    contact_inbox = build_contact_inbox(contact: contact)
    conversation = build_conversation(contact: contact, contact_inbox: contact_inbox)
    build_message(content: content, conversation: conversation)
  end
end
