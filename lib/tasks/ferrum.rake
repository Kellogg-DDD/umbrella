task(:scrape) do
  browser = Ferrum::Browser.new({
    :browser_options => { "no-sandbox": true },
    :timeout => 30
  })

  browser.goto("https://www.senate.gov/senators/contact")

  all_senator_links = browser.css("div.contenttext a")
  
  # The .pop removes the very last link, which is empty. Data cleaning woes.
  all_senator_links.pop

  # Create a blank array to hold all of the results, ultimately
  all_senators = Array.new

  # The .each_slice method gives you two, or however many, elements at a time
  # Since, through exploration, I discovered that the links come in pairs, I
  # can use this method to deal with both the name and the contact pages in the
  # same block
  all_senator_links.each_slice(2) do |senate_page_link, contact_page_link|
    # Create a blank hash to hold this senator
    senator = Hash.new

    senator_name = senate_page_link.text.strip

    p "Scraping info for #{senator_name}..."

    senator.store(:name, senator_name)

    senator_contact_url = contact_page_link.attribute(:href)
    
    begin
      contact_page_browser = Ferrum::Browser.new({
        :browser_options => { "no-sandbox": true },
        :timeout => 30
      })    

      contact_page_browser.goto(senator_contact_url)

      all_twitter_links = contact_page_browser.css('[href*="twitter.com"]')

      # Create a blank array to hold any URLs that lead to Twitter
      twitter_urls = Array.new

      all_twitter_links.each do |twitter_link|
        # Drop the ones that lead to tweets
        if twitter_link.attribute(:href).exclude?("/status/")
          # Keep the ones that probably lead to profiles
          twitter_urls.push(twitter_link.attribute(:href).downcase)
        end
      end

      senator.store(:handles, twitter_urls.uniq)
      
      all_senators.push(senator)

      p senator

      contact_page_browser.quit
    rescue => error
      senator.store(:handles, [error.message])

      all_senators.push(senator)

      p senator
    end
  end

  p all_senators
  
  browser.quit
end
