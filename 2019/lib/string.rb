require 'artii'
class String
  def big
    Artii::Base.new.asciify(self)
  end
end