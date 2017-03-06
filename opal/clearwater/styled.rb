require 'clearwater/component'
require 'clearwater/component/html_tags'

module Styled
  module_function

  Clearwater::Component::HTML_TAGS.each do |tag_name|
    define_method tag_name do |style|
      component(tag_name, style)
    end
  end

  def component type, style
    Class.new(Component) do
      @cached_styles = {}

      define_method :initialize do |props, children|
        # Allow taking just children and no props
        if children.nil? && `!props.$$is_hash`
          children = props
          props = {}
        end

        # TODO: Only iterate through this once
        @events = props.select { |key| key.start_with? 'on' }
        @props = props.reject { |key| key.start_with? 'on' }

        @children = children
      end

      define_method :render do
        class_name = class_name_for(@props)
        add_style class_name, styles_for(@props, style)
        tag(type, { className: class_name }.merge(@events), @children)
      end
    end
  end

  class Component
    include Clearwater::Component

    def styles_for props, style, pseudo: nil
      cached_styles = self.class.cached_styles

      return cached_styles[[props, pseudo]] if cached_styles.key? [props, pseudo]

      dot_props = Props.new(props)
      class_name = class_name_for(props)

      styles = style.reject { |key, value| key.start_with? '&' }
      pseudo_styles = style.select { |key, value| key.start_with? '&' }

      [
        [
          ".#{class_name}#{":#{pseudo}" if pseudo}{",
          styles.map do |key, value|
            value = value.call(dot_props) if `!!#{value}.$$is_proc`
            "#{key.gsub('_', '-')}: #{value};"
          end.join,
          '}',
        ].join,
        pseudo_styles.map do |pseudo, style|
          styles_for(props, style, pseudo: pseudo.sub('&:', ''))
        end,
      ].flatten
    end

    def add_style class_name, styles
      @@cached_classes ||= {}

      return if @@cached_classes.key? class_name

      @@cached_classes[class_name] = true

      element = self.class.style_element
      styles.each do |style|
        `#{element}.appendChild(document.createTextNode(#{style}))`
      end
    end

    def class_name_for props
      "Styled-Component-#{self.class.hash}--#{props.hash.gsub(/\W+/, '-')}"
    end

    def self.cached_styles
      @cached_styles
    end

    def self.style_element
      @style_element ||= begin
                           element = `document.createElement('style')`
                           `document.head.append(#{element})`
                           element
                         end
    end
  end

  class Props
    def initialize hash
      @hash = hash
    end

    def hash
      @hash.hash
    end

    def eql? other
      @hash.eql? other.to_h
    end

    def to_h
      @hash
    end

    def method_missing key
      self[key]
    end

    def [] key
      @hash[key]
    end
  end
end
