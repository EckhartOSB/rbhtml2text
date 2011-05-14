#!/usr/bin/env ruby
require 'rubygems'
require 'htmlentities'

def html2text(html)
  text = html.
    gsub(/(&nbsp;|\n|\s)+/im, ' ').squeeze(' ').strip.
    gsub(/<([^\s]+)[^>]*(src|href)=\s*(.?)([^>\s]*)\3[^>]*>\4<\/\1>/i, '\4')

  links = []
  linkregex = /<[^>]*(src|href)=\s*(.?)([^>\s]*)\2[^>]*>\s*/i
  while linkregex.match(text)
    links << $~[3]
    alt = ''
    if /\b(title|alt)=(['"])(.*?)\2/.match($~[0])
      alt = '[' + $~[3] + ']'
    end
    text.sub!(linkregex, "[#{links.size}]#{alt}")
  end

  decoder = HTMLEntities.new

  text = decoder.decode(
    text.
      gsub(/<(script|style)[^>]*>.*<\/\1>/im, '').
      gsub(/<!--.*-->/m, '').
      gsub(/<hr(| [^>]*)>/i, "___\n").
      gsub(/<li(| [^>]*)>/i, "\n* ").
      gsub(/<blockquote(| [^>]*)>/i, '> ').
      gsub(/<(br)(\/?| [^>]*)>/i, "\n").
      gsub(/<(\/h[\d]+|p)(| [^>]*)>/i, "\n\n").
      gsub(/<[^>]*>/, '')
  ).lstrip.gsub(/\n[ ]+/, "\n") + "\n"

  for i in (0...links.size).to_a
    text = text + "\n  [#{i+1}] <#{decoder.decode(links[i])}>" unless links[i].nil?
  end
  links = nil
  text
end

if __FILE__ == $0	# run from command line
  puts html2text($<.read)
end
