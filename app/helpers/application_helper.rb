# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def apply_webkit_hack(stylesheets)
    css = stylesheets.collect do |fn| 
      File.read("#{RAILS_ROOT}/public/stylesheets/#{fn}.css")
    end.join("\n")

    content_tag("style", css.scan(/^.*?!wk-hack.*?$/).join("\n"))
  end
end
