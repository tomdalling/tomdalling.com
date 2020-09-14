module Statue
  class RSS
    class GUID
      value_semantics do
        value String
        permalink? Bool()
      end
    end

    class Item
      value_semantics do
        title String
        url Addressable::URI
        description String
        published_at Time
        category String
        guid GUID
      end

      def build(parent)
        parent.item do
          _1.title(title)
          _1.link(url)
          _1.description { parent.cdata(description.strip + "\n") }
          _1.pubDate(published_at.rfc822)
          _1.category { parent.cdata(category) }
          _1.guid(guid.value, isPermaLink: guid.permalink?)
        end
      end
    end

    value_semantics do
      title String
      site_url Addressable::URI
      rss_url Addressable::URI
      description String
      language String
      generator String
      update_period String
      update_frequency Integer
      items ArrayOf(Item)
    end

    def to_xml
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.rss(
          'version' => '2.0',
          'xmlns:atom' => "http://www.w3.org/2005/Atom",
          'xmlns:sy' => 'http://purl.org/rss/1.0/modules/syndication/',
        ) do |rss|
          rss.channel do |channel|
            channel.title(title)
            channel.link(site_url)
            channel.send('atom:link',
              href: rss_url,
              rel: 'self',
              type: "application/rss+xml",
            )
            channel.description(description)
            channel.language(language)
            channel.generator(generator)
            channel.send('sy:updatePeriod', update_period)
            channel.send('sy:updateFrequency', update_frequency.to_s)
            items.sort_by(&:published_at).reverse.each { _1.build(channel) }
          end
        end
      end.to_xml
    end
  end
end
