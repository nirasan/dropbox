class NoticeMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  default from: "from@example.com"
  def share(user, node)
    @user = user
    @node = node
    mail(to: @user.email, subject: "ファイル共有のお知らせ") do |format|
      format.html
    end
  end
end
