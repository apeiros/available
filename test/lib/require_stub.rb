module RequireStub
  @available_libs = {}
  @available_gems = {}
  @activated_gems = {}
  @required_libs  = {}

  class << self
    attr_reader :available_libs, :available_gems, :required_libs
  end

  def self.reset!
    @available_libs.clear
    @available_gems.clear
    @activated_gems.clear
    @required_libs.clear
  end

  def self.add_available_libs(*args)
    args.each do |arg|
      @available_libs[arg.to_s] = true
    end
  end

  def self.add_available_gem(name, require_path=nil, version=nil)
    require_path ||= name
    version      ||= '0.0.1'
    @available_libs[require_path] = [name, require_path, version]
  end

private
  def require(name, *)
    return false if RequireStub.required_libs[name]
    return true if RequireStub.available_libs[name]
    raise LoadError, "cannot load such file -- #{name}"
  end
end