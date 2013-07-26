module WardenHelper
  
  def warden_stubs
    allow_message_expectations_on_nil()
    request.env['warden'].stub(:custom_failure!)
  end
  
end
