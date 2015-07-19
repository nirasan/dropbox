class ShareUser < ActiveRecord::Base
  belongs_to :node
  belongs_to :user

  after_create :send_notice_mail
  def send_notice_mail
    NoticeMailer.share(user, node).deliver
  end
end
