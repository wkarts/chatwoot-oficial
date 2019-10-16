class User < ApplicationRecord
  include Events::Types
  include Pubsubable

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :confirmable

  validates_uniqueness_of :email, scope: :account_id
  validates :account_id, presence: true

  enum role: [:agent, :administrator]

  belongs_to :devise_user
  belongs_to :account
  belongs_to :inviter, class_name: 'User', required: false

  has_many :assigned_conversations, foreign_key: 'assignee_id', class_name: 'Conversation', dependent: :nullify
  has_many :inbox_members, dependent: :destroy
  has_many :assigned_inboxes, through: :inbox_members, source: :inbox
  has_many :messages

<<<<<<< HEAD
  before_validation :set_password_and_uid, on: :create

=======
>>>>>>> Move devise-specific model methods to DeviseUser
  accepts_nested_attributes_for :account

  before_create :set_channel
  after_create :notify_creation
  after_destroy :notify_deletion

<<<<<<< HEAD
  def set_password_and_uid
    self.uid = email
  end

=======
>>>>>>> Move devise-specific model methods to DeviseUser
  def serializable_hash(options = nil)
    super(options).merge(confirmed: confirmed?, subscription: account.try(:subscription).try(:summary))
  end

  def notify_creation
    Rails.configuration.dispatcher.dispatch(AGENT_ADDED, Time.zone.now, account: account)
  end

  def notify_deletion
    Rails.configuration.dispatcher.dispatch(AGENT_REMOVED, Time.zone.now, account: account)
  end

  def push_event_data
    {
      name: name
    }
  end
end
