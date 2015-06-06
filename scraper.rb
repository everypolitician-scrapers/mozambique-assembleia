#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'date'
require 'open-uri'
require 'date'
require 'csv'

# require 'colorize'
# require 'pry'
# require 'csv'
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape_list(url)
  warn "Getting #{url}"
  noko = noko_for(url)
  binding.pry
  noko.css('#ja-content-main table').first.xpath('.//tr[td[@class="xl68"]]').each do |row|
    tds = row.css('td')
    data = { 
      id: tds[0].text.strip,
      name: tds[1].text.strip,
      party: "Unknown",
      party_id: "unknown",
      constituency: "Unknown",
      source: url,
      term: 8,
    }
    ScraperWiki.save_sqlite([:id, :term], data)
  end
end

term = {
  id: 8,
  name: 'VIII Legislature',
  start_date: '2011-07-09',
}
ScraperWiki.save_sqlite([:id], term, 'terms')

scrape_list('http://www.parlamento.mz/deputados/deputado/lista-alfabetica')

