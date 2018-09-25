class ActiveSupport::TimeWithZone
  def as_json(options = {})
    self.to_s(:default)
  end
end