class ErrorSerializer < Lucky::Serializer
  def initialize(
    @message : String,
    @details : String? = nil,
    @param : String? = nil # so you can track which param (if any) caused the problem
  )
  end

  def render
    {message: @message, param: @param, details: @details}
  end
end
