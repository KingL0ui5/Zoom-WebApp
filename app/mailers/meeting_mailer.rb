class MeetingMailer < ApplicationMailer
  layout 'mailer'
  
  def meeting_email(recipitent_name, reciptitent_email, meeting_details, sender_name) #for particpiants
    @meetinginfo = meeting_details
    @recipitent_name = recipitent_name
    @sender_name = sender_name
    
    mail(to: reciptitent_email, subject: "#{@sender_name} from VanishingFunds has invited you to a meeting!")
  end
  
  def meeting_host_email(host_email, details, host_name) #for meeting host with start link 
    @meetinginfo = details
    @name = host_name
    
    mail(to: host_email, subject: "Here are the details for your new meeting #{@name}" )
  end
  
  def meeting_confirmation_email(host_email, details, host_name) #for meeting host (confirmation of meeting schedule)
    @meetinginfo = details
    @name = host_name
    
    mail(to: host_email, subject: "Hello #{@name}, your meeting has been scheduled" )
  end 
end
