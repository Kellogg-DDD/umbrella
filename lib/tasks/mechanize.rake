task(:mechanize) do
  agent = Mechanize.new
  senate_page = agent.get('https://www.senate.gov/senators/contact')

  all_senator_links = senate_page.links_with({ :css => "div.contenttext a" })
  
  # The .pop removes the very last link, which is empty. Data cleaning woes.
  all_senator_links.pop

  # Create a blank array to hold all of the results, ultimately
  all_senators = Array.new

  # The .each_slice method gives you two, or however many, elements at a time
  #   Since, through exploration, I discovered that the links come in pairs, I
  #   can use this method to deal with both the name and the contact pages in the
  #   same block.
  all_senator_links.each_slice(2) do |senate_page_link, contact_page_link|
    # Create a blank hash to hold this senator
    senator = Hash.new

    senator_name = senate_page_link.text.strip

    p "Scraping info for #{senator_name}..."

    senator.store(:name, senator_name)

    begin
      # The begin/rescue/end structure protects against unforeseen
      #   errors, like one senator's page being down. We don't want
      #   that to interrupt our whole scraping job.

      senator_contact_page = contact_page_link.click

      all_twitter_links = senator_contact_page.links_with({ :css => '[href*="twitter.com"]' })

      # Create a blank array to hold any URLs that lead to Twitter
      twitter_urls = Array.new

      all_twitter_links.each do |twitter_link|
        # Drop the ones that lead to tweets
        if twitter_link.href.exclude?("/status/")
          # Keep the ones that probably lead to profiles
          twitter_urls.push(twitter_link.href.downcase)
        end
      end

      senator.store(:handles, twitter_urls.uniq)
    rescue => error
      # If one senator's page is down and causes an error, we'll store
      #   the error message instead.
      senator.store(:handles, [error.message])
    end
    
    all_senators.push(senator)

    p senator
  end

  p all_senators
end
