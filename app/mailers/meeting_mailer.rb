class MeetingMailer < ApplicationMailer
  layout 'mailer'
  default from: 'notifications@vanishingfunds.com'
  
  def meeting_email(recipitent_name, reciptitent_email, meeting_details, sender_name)
    @meetinginfo = meeting_details
    @recipitent_name = recipitent_name
    
    mail(to: reciptitent_email, subject: "You have been invited to a meeting by #{sender_name}", from: @meetinginfo[:host])
  end
end
