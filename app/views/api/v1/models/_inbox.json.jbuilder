json.id resource.id
json.channel_id resource.channel_id
json.name resource.name
json.channel_type resource.channel_type
json.greeting_enabled resource.greeting_enabled
json.greeting_message resource.greeting_message
json.working_hours_enabled resource.working_hours_enabled
json.out_of_office_message resource.out_of_office_message
json.working_hours resource.weekly_schedule
json.timezone resource.timezone
json.avatar_url resource.try(:avatar_url)
json.page_id resource.channel.try(:page_id)
json.widget_color resource.channel.try(:widget_color)
json.website_url resource.channel.try(:website_url)
json.welcome_title resource.channel.try(:welcome_title)
json.welcome_tagline resource.channel.try(:welcome_tagline)
json.enable_auto_assignment resource.enable_auto_assignment
json.web_widget_script resource.channel.try(:web_widget_script)
json.website_token resource.channel.try(:website_token)
json.forward_to_email resource.channel.try(:forward_to_email)
json.phone_number resource.channel.try(:phone_number)
json.selected_feature_flags resource.channel.try(:selected_feature_flags)
json.reply_time resource.channel.try(:reply_time)
json.reauthorization_required resource.channel.try(:reauthorization_required?) if resource.facebook?
json.agent_bot do
  json.partial! 'api/v1/models/agent_bot.json.jbuilder', resource: resource.agent_bot if resource.agent_bot.present?
end
if resource.web_widget?
  json.hmac_token resource.channel.try(:hmac_token)
  json.pre_chat_form_enabled resource.channel.try(:pre_chat_form_enabled)
  json.pre_chat_form_options resource.channel.try(:pre_chat_form_options)
end
