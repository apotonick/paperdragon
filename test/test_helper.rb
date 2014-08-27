require 'paperdragon'
require 'minitest/autorun'

MiniTest::Spec.class_eval do
  def exists?(uid)
    File.exists?("public/paperdragon/" + uid)
  end

  def generate_uid
    Dragonfly.app.datastore.send(:relative_path_for, "aptomo.png")
  end

  def self.it(name=nil, *args)
    name ||= Random.rand
    super
  end
end