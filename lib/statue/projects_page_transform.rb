module Statue
  class ProjectsPageTransform < DOMTransform
    def transform(projects)
      clone_each('ul.projects-list li', projects) do |project|
        attrs!(style: [
          "background-color: #{project.background_color}",
          "color: #{project.color}",
          "border-color: #{project.accent_color}",
        ].join(';'))
        at('img.project-image', src: "/images/projects/#{project.slug}.png", alt: project.title)
        at('a.project-title', project.title, href: project.url, style: "color: #{project.accent_color}")
        at('p.project-description', project.description)
        at('a.project-link', href: project.url, style: "color: #{project.accent_color}; border-color: #{project.accent_color}")
      end
    end
  end
end
