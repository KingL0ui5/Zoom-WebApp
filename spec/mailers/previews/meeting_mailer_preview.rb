# Preview all emails at http://localhost:3000/rails/mailers/meeting_mailer
class MeetingMailerPreview < ActionMailer::Preview
  def meeting_email
    details = {
      message: 'Please join this meeting',
      host: 'host@vanishingfunds.com',
      topic: 'topic',
      join_url: 'zoom.us/join_url',
      duration: '60',
      start_time: '12:00',
      timezone: 'GMT',
      start_url: 'zoom.us/start_url'
    }
    MeetingMailer.meeting_email("particpiant", "particpiant@vanishingfunds.com", details, "host")
  end
  
  def meeting_host_email
    details = {
      message: 'Please join this meeting',
      host: 'host@vanishingfunds.com',
      topic: 'topic',
      join_url: 'zoom.us/',
      duration: '60',
      start_time: '12:00',
      timezone: 'GMT',
      start_url: 'start_url'
    }
    MeetingMailer.meeting_host_email("host@vanishingfunds.com", details, "host")
  end
  
  def meeting_confirmation_email
    details = {
      message: 'Please join this meeting',
      host: 'host@vanishingfunds.com',
      topic: 'topic',
      join_url: 'zoom.us/',
      duration: '60',
      start_time: '12:00',
      timezone: 'GMT',
      start_url: 'start_url'
    }
    
    MeetingMailer.meeting_confirmation_email("host@vanishingfunds.com", details, "host")
  end
end
