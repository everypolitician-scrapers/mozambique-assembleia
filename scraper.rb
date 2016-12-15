#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'date'
require 'open-uri'
require 'date'
require 'csv'
require 'set'

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

  count = 0
  @parties = { 
    'BANCADA PARLAMENTAR DA FRELIMO' => 'FRELIMO',
    'BANCADA PARLAMENTAR DA RENAMO' => 'RENAMO',
    'PARTIDO MOVIMENTO DEMOCRÁTICO DE MOÇAMBIQUE' => 'MDM'
  }

  @parties.each do |party, party_id|
    head = noko.css('#ja-content-main table').xpath('.//td[@colspan=3]').find { |n| n.text.gsub(/[[:space:]]+/,' ').strip == party }
    areas = head.xpath('.//following::td[@colspan=3]').take_while { |n| !@parties[n.text] }

    areas.each do |area|
      rows = area.xpath('.//following::tr').take_while { |n| n.css('td').count > 1 }
      rows.drop(1).each do |row|
        tds = row.css('td')
        { male: 0, female: 1 }.each do |gender, index|
          name = tds[index].text.gsub(/[[:space:]]+/,' ').strip
          next if name.empty?
          data = { 
            id: 1+count,
            name: name,
            gender: gender.to_s,
            party: party,
            party_id: party_id,
            constituency: area.text,
            source: url,
            term: 8,
          }
          count += 1
          puts data
          ScraperWiki.save_sqlite([:id, :term], data)
        end
      end
    end
  end
  puts "Added #{count}"
end

scrape_list('http://www.parlamento.mz/deputados/deputado/lista-alfabetica/21-deputados/629-genero')

