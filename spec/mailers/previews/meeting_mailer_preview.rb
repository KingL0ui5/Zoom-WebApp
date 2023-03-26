# Preview all emails at http://localhost:3000/rails/mailers/meeting_mailer
class MeetingMailerPreview < ActionMailer::Preview
  def meeting_email
      details = {
      host: ['person@vanishingfunds.com'],
      topic: ['topic'],
      join_url: ['zoom.us/1234'],
      duration: ['60'],
      start_time: ['12:00'],
      timezone: ['GMT'],
      start_url: ['start_url']
    }
    MeetingMailer.meeting_email("[name]", "[name]@vanishingfunds.com", details, "[name]")
  end
end
