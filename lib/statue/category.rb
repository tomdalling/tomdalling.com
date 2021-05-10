module Statue
  class Category
    value_semantics do
      human_name String
      machine_name String
    end

    def uri
      "/blog/category/#{machine_name}/"
    end

    def self.lookup(name)
      ALL.find { _1.machine_name == name }
    end

    ALL = {
      'software-design' => "Software Design",
      'coding-tips' => "Coding Tips",
      'cocoa' => "Cocoa",
      'coding-styleconventions' => "Coding Style/Conventions",
      'software-processes' => "Software Processes",
      'web' => "Web",
      'modern-opengl' => "Modern OpenGL Series",
      'ruby' => "Ruby",
      'random-stuff' => "Miscellaneous",
      'testing' => "Testing",
      'mentoring' => "Mentoring Notes",
    }.map { new(machine_name: _1, human_name: _2) }
  end
end
