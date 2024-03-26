class MailerGateway
  def send(email, subject, message)
    puts "Sending email to #{email} with subject #{subject} and message #{message}"
  end
end
