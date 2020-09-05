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
        url String
        description String
        published_at Time
        category String
        guid GUID
      end

      def to_xml
        doc = Nokogiri::HTML::DocumentFragment.parse("")
        Nokogiri::XML::Builder.with(doc) do |fragment|
          fragment.item do |item|
            item.title(title)
            item.link(url)
            item.description { fragment.cdata(description) }
            item.pubDate(published_at.rfc822)
            item.category { fragment.cdata(category) }
            item.guid(guid.value, isPermaLink: guid.permalink?)
          end
        end
        doc.to_xml
      end
    end

    value_semantics do
      title String
      site_url String #TODO: actual URL
      rss_url String #TODO: actual URL
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
            items.sort_by(&:published_at).reverse.each { xml << _1.to_xml }
          end
        end
      end.to_xml
    end
  end
end
