# == Schema Information
#
# Table name: channel_email
#
#  id                 :bigint           not null, primary key
#  email              :string           not null
#  forward_to_address :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :integer          not null
#
# Indexes
#
#  index_channel_email_on_email               (email) UNIQUE
#  index_channel_email_on_forward_to_address  (forward_to_address) UNIQUE
#

class Channel::Email < ApplicationRecord
  self.table_name = 'channel_email'

  validates :account_id, presence: true
  belongs_to :account
  validates :email, uniqueness: true
  validates :forward_to_address, uniqueness: true

  has_one :inbox, as: :channel, dependent: :destroy
end
