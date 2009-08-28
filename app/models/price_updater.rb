class PriceUpdater
  def initialize(options={})
    if options[:evecentral_url]
      @url_base = options[:evecentral_url]
    else
      @url_base = 'http://api.eve-central.com/api/marketstat'
    end # url base
    
    @region = options[:region] if options[:region]

    @user_agent = "YSHI Tools <http://github.com/OwlManAtt/yshi/tree/master>"
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
      request = Net::HTTP::Get.new(url.request_uri, {"User-Agent" => @user_agent})
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
end # PriceUpdater
