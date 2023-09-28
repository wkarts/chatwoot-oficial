class Integrations::Slack::SlackLinkUnfurlService
  pattr_initialize [:params!, :integration_hook!]

  def perform
    event_links = params.dig(:event, :links)
    return unless event_links

    event_links.each do |link_info|
      unfurl_link(link_info)
    end
  end

  def unfurl_link(link_info)
    url = link_info[:url]
    return unless url

    return unless valid_account?(url)

    conversation = conversation_from_url(url)
    return unless conversation

    user_info = contact_attributes(conversation)
    unfurls = generate_unfurls(url, user_info, conversation.inbox)

    send_unfurls(unfurls, params.dig(:event, :unfurl_id), params.dig(:event, :source))
  end

  private

  def contact_attributes(conversation)
    contact = conversation.contact
    {
      user_name: contact.name.presence || '---',
      email: contact.email.presence || '---',
      phone_number: contact.phone_number.presence || '---',
      company_name: contact.additional_attributes&.dig('company_name').presence || '---'
    }
  end

  def generate_unfurls(url, user_info, inbox)
    Integrations::Slack::LinkUnfurlFormatter.new(
      url: url,
      user_info: user_info,
      inbox_name: inbox.name,
      inbox_type: inbox.channel.name
    ).perform
  end

  def send_unfurls(unfurls, unfurl_id, source)
    slack_service = Integrations::Slack::SendOnSlackService.new(
      message: nil,
      hook: integration_hook
    )
    slack_service.link_unfurl(
      unfurl_id: unfurl_id,
      source: source,
      unfurls: JSON.generate(unfurls)
    )
  end

  def conversation_from_url(url)
    conversation_id = extract_conversation_id(url)
    find_conversation_by_id(conversation_id) if conversation_id
  end

  def find_conversation_by_id(conversation_id)
    Conversation.find_by(display_id: conversation_id)
  end

  def valid_account?(url)
    account_id = extract_account_id(url)
    account_id == integration_hook.account_id.to_s
  end

  def extract_account_id(url)
    account_id_regex = %r{/accounts/(\d+)}
    match_data = url.match(account_id_regex)
    match_data[1] if match_data
  end

  def extract_conversation_id(url)
    conversation_id_regex = %r{/conversations/(\d+)}
    match_data = url.match(conversation_id_regex)
    match_data[1] if match_data
  end
end
