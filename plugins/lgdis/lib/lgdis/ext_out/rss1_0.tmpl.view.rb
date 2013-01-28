class View_rss1_0_tmpl 
  def show 
    print "<?xml version=\"1.0\" encoding=\"#{@encoding}\"?>\n"
    print "<feed xmlns=\"http://www.w3.org/2005/Atom\"\n"
    print "	xmlns:georss=\"http://www.georss.org/georss\">\n"
    print "	<title>#{CGI.escapeHTML(@title.to_s)}</title>\n"
    print "	<subtitle>#{CGI.escapeHTML(@subtitle.to_s)}</subtitle>\n"
    print "	<link href=#{CGI.escapeHTML(@site_url.to_s)}/>\n"
    print "	<updated>#{CGI.escapeHTML(@updated.to_s)}</updated>\n"
    print "	<author>\n"
    print "		<name>#{CGI.escapeHTML(@author.to_s)}</name>\n"
    print "		<email>#{CGI.escapeHTML(@authormail.to_s)}</email>\n"
    print "	</author>\n"
    print "	<id>urn:uuid:#{CGI.escapeHTML(@uuid.to_s)}</id>\n"
    	@items.each do |item|
    print "		<entry>\n"
    print "			<title>#{CGI.escapeHTML(item[:title].to_s)}</title>\n"
    print "			<link href=\"#{item[:url]}\"/>\n"
    print "			<id>urn:uuid:#{item[:uuid]}</id>\n"
    print "			<updated>#{item[:date]}</updated>\n"
    print "			<summary>#{CGI.escapeHTML(item[:description].to_s)}</summary>\n"
    print "			<georss:point>#{item[:point]}</georss:point>\n"
    print "			<georss:line>#{item[:line]}</georss:line>\n"
    print "			<georss:polygon>#{item[:polygon]}</georss:polygon>\n"
    print "		</entry>\n"
    	end
    print "</feed>\n"
  end 
  attr_accessor :encoding, :title, :subtitle, :site_url, :updated, :author, :authormail, :uuid, :items
end 
