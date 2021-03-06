class TextMessagesController < ApplicationController

  # twilio account information
  TWILIO_NUMBER = "+14692405270"
  ACCOUNT_SID = 'AC6feca88520eeb03595566c38cf0f83bd'
  AUTH_TOKEN = 'e85ce621d470dd77daf611ec60f7605e'

  # GET /text_messages/new
  def new
    @text_message = TextMessage.new
    render :new
  end

  # POST /text_messages
  def create
    @text_message = TextMessage.new(params[:text_message])

    if @text_message.valid?

      successes = []
      errors = []
      numbers = @text_message.numbers_array
      account = Twilio::REST::Client.new(ACCOUNT_SID, AUTH_TOKEN).account
      numbers.each do |number|

        logger.info "sending message: #{@text_message.message} to: #{number}"

        begin
          account.sms.messages.create(
              :from => TWILIO_NUMBER,
              :to => "+91#{number}",
              :body => @text_message.message
          )
          successes << "#{number}"
        rescue Exception => e
          logger.error "error sending message: #{e.to_s}"
          errors << e.to_s
        end
      end

      flash[:errors] = errors
      flash[:successes] = successes
      if (flash[:errors].any?)
        render :action => :status, :status => :bad_request
      else
        render :action => :status
      end

    else
      render :action => :new, :status => :bad_request
    end
  end

end
