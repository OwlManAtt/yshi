class MarketController < ApplicationController
  def index
    @revenue_detail = CorpOrder.activity_summary
    @revenue_detail_total = @revenue_detail.values.inject {|total,v| total + v}
    @lastest_sell_orders = CorpOrder.find_latest_sell_orders
  end

  def corp_order_history_piechart
    g = Gruff::Pie.new(550)
    g.title = "YSHI Revenue - Last 30 Days"
    g.theme = {
      :colors => ['#87A284','#CCCFBC','#EBEFD1','#DADFB5','#CCCFBC'],
      :marker_color => 'black',
      :font_color => 'black',
      :background_colors => 'transparent' 
    }

    CorpOrder.activity_summary.each {|label,value|
      g.data(label, value)
    }

    send_data(g.to_blob, 
      :disposition => 'inline', 
      :type => 'image/png', 
      :filename => 'corp_activities.png'
    )
  end # corp_order_history_piechart
end
