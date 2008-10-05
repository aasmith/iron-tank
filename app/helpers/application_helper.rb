# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def apply_webkit_hack(stylesheets)
    css = stylesheets.collect do |fn| 
      File.read("#{RAILS_ROOT}/public/stylesheets/#{fn}.css")
    end.join("\n")

    content_tag("style", css.scan(/^.*?!wk-hack.*?$/).join("\n"))
  end

  def pretty_date(date, show_month = true)
    ordinal_day = date.day.ordinalize
    ordinal_day.sub!(/[[:alpha:]]+/){ |m| content_tag("sup", m) }

    date_fmt = "%A, %%s"
    date_fmt << " %B" if show_month
    date.strftime(date_fmt) % ordinal_day
  end
end
