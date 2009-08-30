class PriceUpdater
  UserAgent = "YSHI Tools <http://github.com/OwlManAtt/yshi/tree/master>"

  class MarketStat
    def initialize(options={})
      if options[:evecentral_url]
        @url_base = options[:evecentral_url]
      else
        @url_base = 'http://api.eve-central.com/api/marketstat'
      end # url base
      
      @region = options[:region] if options[:region]
    end # initialize

    def update
      price_hash = parse_xml(fetch_xml_doc(build_url))
      price_hash.each {|item_id,price|
        MaterialPrice.new({:item_type_id => item_id, :price => price, :archived => false}).save      
      }
    end # update

    private 
    def parse_xml(xml)
      price_data = {}

      doc = REXML::Document.new(xml)
      doc.root.elements.first.elements.each {|type| price_data[type.attributes['id'].to_i] = type.elements['all/median'].text.to_f}

      return price_data
    end

    def fetch_xml_doc(url)
      url = URI.parse(url)

      http = Net::HTTP.new(url.host, url.port)
      http.read_timeout = 60
      http.start do |http|
        request = Net::HTTP::Get.new(url.request_uri, {"User-Agent" => PriceUpdater::UserAgent})
        response = http.request(request)
        xml = response.body
      end
    end

    def build_url
      type_list = get_item_list.map {|id| "typeid=#{id}" }.join '&'
      request_url = "#{@url_base}?#{type_list}"
      
      # TODO support an array of region IDs. 
      if @region
        request_url << "&regionlimit=#{@region}"
      end

      return request_url 
    end

    def get_item_list
      list = []

      # MySQLResult doesn't have #map()...
      ActiveRecord::Base.connection.execute('SELECT DISTINCT material_type_id FROM blueprints INNER JOIN blueprint_materials ON blueprints.id = blueprint_materials.blueprint_id INNER JOIN item_groups ON blueprint_materials.item_group_id = item_groups.id WHERE item_groups.poll_price = 1 AND blueprints.tech_level = 1').each {|row| list << row.first} 

      return list
    end
  end # MarketStat

  # Run this at 7 AM EST for the previous day
  class MarketLog 
    def initialize(options={})
      if options[:evecentral_url]
        @url = options[:evecentral_url]
        @file = URI.parse(@url).path.split('/').last
      else
        @file = "#{Time.new.yesterday.strftime('%Y-%m-%d')}.dump.gz"
        @url = "http://eve-central.com/dumps/#{@file}"
      end # url
      
      @file_path = File.join(RAILS_ROOT,'tmp','market_data',@file)
    end # initialize
    
    def download
      url = URI.parse(@url)

      http = Net::HTTP.new(url.host, url.port)
      http.start do |http|
        request = Net::HTTP::Get.new(url.request_uri, {"User-Agent" => PriceUpdater::UserAgent})
        response = http.request(request)

        open(@file_path, 'wb') do |file|
          file.write(response.body)
        end
      end

      `gunzip --force --quiet #{@file_path}`
      raise "Gunzip failed on #{@file_path} with status #{$?.exitstatus}." if $?.exitstatus != 0
    end

    def load
      ActiveRecord::Base.connection.execute('TRUNCATE market_log_import')

      file = @file_path.gsub(/\.gz$/,'')
      sql = "LOAD DATA LOCAL INFILE '#{file}' 
      INTO TABLE market_log_import 
      FIELDS TERMINATED BY ',' 
      LINES TERMINATED BY '\n' 
      IGNORE 1 LINES (order_id,region_id,systemid,station_id,type_id,bid,price,minvolume,volremain,volenter,issued,duration,range,reportedby,reportedtime);"
      ActiveRecord::Base.connection.execute(sql)

      sql = "INSERT IGNORE INTO market_datas
      (market_order_id,item_type_id,order_type,price,order_placed_at,station_id,station_name)
      SELECT 
        order_id AS market_order_id,
        market_log_import.type_id AS item_type_id,
        IF(market_log_import.bid=0,'sell','buy') AS order_type,
        IF(market_log_import.bid=0,market_log_import.price,market_log_import.bid) AS price,  
        FROM_UNIXTIME(UNIX_TIMESTAMP(LEFT(RTRIM(LTRIM(issued)),19))) AS order_placed_at,
        trade_hubs.id,
        trade_hubs.station_name
      FROM market_log_import 
      INNER JOIN trade_hubs ON market_log_import.station_id = trade_hubs.id"
      ActiveRecord::Base.connection.execute(sql)
    end
  end # QuickLook
end # PriceUpdater
