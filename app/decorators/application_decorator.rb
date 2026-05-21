class ApplicationDecorator < SimpleDelegator
  def self.decorate(object)
    new(object)
  end

  def self.decorate_collection(collection)
    collection.map { |object| new(object) }
  end

  def to_partial_path
    __getobj__.to_partial_path
  end

  def model_name
    __getobj__.model_name
  end
end
