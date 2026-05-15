module Statue
  class ProjectsPageOutput
    attr_reader :projects, :template

    def initialize(projects, template:)
      @projects = projects
      @template = template
    end

    def description
      "Projects Page"
    end

    def write_to(io)
      io.write(template.html(projects))
    end

    def reset
      template.reset
    end

    def modified_since?(mtime)
      template.modified_since?(mtime) || projects.any? { _1.modified_since?(mtime) }
    end
  end
end
