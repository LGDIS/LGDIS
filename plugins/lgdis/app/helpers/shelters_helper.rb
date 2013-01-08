# encoding: utf-8
module SheltersHelper
  include ApplicationHelper

=begin
  def label_tag_for_field_of(key, options = {}, &block)
    label = options[:label].is_a?(Symbol) ? l(options[:label]) : options[:label]
    label ||= localize_scoped(key)
    label += (options.delete(:required) ? content_tag("span", " *", :class => "required"): "")
    
    content_tag("label", :class => options[:class]) do
      yield key, label.html_safe
    end
  end
=end
  
  def localize_scoped(key)
    begin
      localized = l(("field_"+key.to_s).to_sym, :scope => params[:controller], :raise => true)
    rescue
    end
    localized ||= l(("field_"+key.to_s).to_sym)
  end

  def field_for(key, options = {}, html_options = {}, &block)
    label = options[:label].is_a?(Symbol) ? l(options[:label]) : options[:label]
    label ||= localize_scoped(key)
    label += (options.delete(:required) ? content_tag("span", " *", :class => "required"): "")
    
    content_tag("p", html_options) do
      yield key, label.html_safe
    end
  end
end
