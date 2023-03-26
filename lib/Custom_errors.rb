class FormatError < StandardError
  def initialize(message = "Format of response must be handled seperately")
    super(message) #default message
  end
end
