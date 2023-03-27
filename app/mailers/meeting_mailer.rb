class MeetingMailer < ApplicationMailer
  layout 'mailer'
  default from: 'notifications@vanishingfunds.com'
  
  def meeting_email(recipitent_name, reciptitent_email, meeting_details, sender_name)
    @meetinginfo = meeting_details
    @recipitent_name = recipitent_name
    @sender_name = sender_name
    
    mail(to: reciptitent_email, subject: "#{@sender_name} from VanishingFunds has invited you to a meeting!", from: @meetinginfo[:host])
  end
  
  def meeting_host_email(email, details, name)
    @meetinginfo = details
    @name = name
    
    mail(to: email, subject: "Here are the details for your new meeting #{@name}" )
  end
  
  def meeting_confirmation_email(email, details, name)
    @meetinginfo = details
    @name = name
    
    mail(to: email, subject: "#{@name}, your meeting has been scheduled" )
  end 
end
