struct CliOptions
  property concurrent, url, iterations

  def initialize(@concurrent : Bool, @url : String, @iterations : Int32)
  end
end
