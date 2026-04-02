module Statue
  class Post
    attr_reader :markdown_file, :content_transform

    def initialize(markdown_file, content_transform:)
      @markdown_file = markdown_file
      @content_transform = content_transform
    end

    extend Forwardable
    def_delegators :frontmatter,
      *%i(title deprecated_category disqus_id draft? main_image)

    def_delegator :markdown_file, :modified_since?

    def tags
      (frontmatter.tags + [deprecated_category].compact).uniq
    end

    def tagged?(tag)
      raise ArgumentError unless tag.is_a?(Tag)
      tags.include?(tag)
    end

    def machine_name
      basename.partition('_').last
    end

    def path
      Pathname.new("blog") / machine_name / 'index.html'
    end

    def old_categorised_path
      if deprecated_category
        Pathname.new("blog") / deprecated_category.machine_name / machine_name / 'index.html'
      else
        nil
      end
    end

    def uri
      "/#{path.dirname}/"
    end

    def url
      BASE_URL / uri
    end

    def unique_id
      disqus_id || "com.tomdalling.blog.#{machine_name}"
    end

    def github_url
      GITHUB_BASE_URL / markdown_file.full_path.relative_path_from(PROJECT_ROOT)
    end

    def basename
      markdown_file.path.basename.sub_ext('').to_s
    end

    def bleet?
      tags.map(&:machine_name).include?('bleet')
    end

    def date
      Date.iso8601(basename.partition('_').first)
    rescue Date::Error => ex
      raise "Failed to extract date from #{basename} (did you separate it with an underscore?)"
    end

    def human_date
      date.strftime("%d %b, %Y")
    end

    def frontmatter
      @frontmatter ||= Frontmatter.from_edn(loaded.first)
    end

    def social_metadata
      @social_metadata ||= SocialMetadata.new(
        title: title,
        image_url:
          if main_image&.uri
            BASE_URL / main_image.uri
          else
            nil
          end
      )
    end

    def content
      loaded.last
    end

    def html
      @html ||= transform_content_html(Markdown.to_html(content))
    end

    def preview_html
      more_separator = '<!--more-->'
      @preview_html ||=
        if html.include?(more_separator)
          html.partition(more_separator).first
        else
          html
        end
    end

    def <=>(other)
      # most recent to oldest
      -(date <=> other.date)
    end

    def reset
      @frontmatter = nil
      @html = nil
      @preview_html = nil
      @loaded = nil
    end

    private

      def loaded
        @loaded ||= EDN.split_frontmatter(markdown_file.read)
      rescue => ex
        raise "Failed to load #{markdown_file.path}: #{ex}"
      end

      def transform_content_html(html)
        Nokogiri::HTML.fragment(html)
          .tap { content_transform.(_1) }
          .to_html
      end

      class Artist
        value_semantics do
          name String
          url String
        end
      end

      class MainImage
        value_semantics do
          uri Pathname, coerce: PathnameCoercer
          visible? Bool(), default: true
          artist Either(Artist, nil), coerce: true, default: nil
        end

        def self.coerce_artist(obj)
          if obj
            Artist.coercer.(obj)
          else
            obj
          end
        end

        def show?
          visible? && uri
        end
      end

      class Frontmatter
        value_semantics do
          title String
          disqus_id Either(String, nil)
          deprecated_category Either(Tag, nil), coerce: true
          tags ArrayOf(Tag), default: [], coerce: true
          draft? Bool()
          main_image Either(MainImage, nil), coerce: true, default: nil
        end

        def self.coerce_deprecated_category(obj)
          if obj.is_a?(Symbol)
            Tag.lookup(obj.to_s) || obj
          elsif obj.is_a?(String)
            Tag.lookup(obj) || obj
          else
            obj
          end
        end

        def self.coerce_tags(obj)
          if obj.is_a?(Array)
            obj.map do |e|
              e.is_a?(Symbol) ? Tag.lookup(e.to_s) : e
            end
          else
            obj
          end
        end

        def self.coerce_main_image(obj)
          if obj
            MainImage.coercer.(obj)
          else
            obj
          end
        end

        def self.from_edn(edn)
          new(
            title: edn.fetch(:title),
            disqus_id: edn.fetch(:'disqus-id', nil),
            deprecated_category: edn.fetch(:'deprecated-category', nil),
            tags: edn.fetch(:tags, []),
            draft?: edn.fetch(:draft, false),
            main_image: edn.fetch(:'main-image', nil),
          )
        end
      end

  end
end
