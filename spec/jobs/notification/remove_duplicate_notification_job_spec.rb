require 'rails_helper'

RSpec.describe Notification::RemoveDuplicateNotificationJob do
  subject(:job) { described_class.perform_later }

  it 'enqueues the job' do
    expect { job }.to have_enqueued_job(described_class)
      .on_queue('default')
  end
end
