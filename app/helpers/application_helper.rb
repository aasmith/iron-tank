# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def apply_webkit_hack(stylesheets)
    css = stylesheets.collect do |fn| 
      File.read("#{RAILS_ROOT}/public/stylesheets/#{fn}.css")
    end.join("\n")

    content_tag("style", css.scan(/^.*?!wk-hack.*?$/).join("\n"))
  end

  def pretty_date(date)
    ordinal_day = date.day.ordinalize
    ordinal_day.sub!(/[[:alpha:]]+/){ |m| content_tag("sup", m) }

    date.strftime("%A, %%s %B") % ordinal_day
  end
end
