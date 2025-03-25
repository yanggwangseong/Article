module Jekyll
    class TagPageGenerator < Generator
      safe true
  
      def generate(site)
        tags = []
        
        site.collections['notes'].docs.each do |post|
          if post.data['tags']
            tags.concat(post.data['tags'])
          end
        end
  
        tags.uniq.each do |tag|
          site.pages << TagPage.new(site, site.source, 'tags', tag)
        end
      end
    end
  
    class TagPage < Page
      def initialize(site, base, dir, tag)
        @site = site
        @base = base
        @dir = dir
        @name = "#{tag}.html"
  
        self.process(@name)
        self.read_yaml(File.join(base, '_layouts'), 'tag.html')
        self.data['tag'] = tag
        self.data['title'] = "태그: #{tag}"
      end
    end
  end
  