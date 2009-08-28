# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def number_to_isk(amount)
    number_with_delimiter(amount.round(2)).to_s << ' isk'
  end

  def fagify_text(source_text)
    colours = ['00FFFF','FF7F50','7FFF00','DC143C','8B008B',
      '8FBC8F','CD5C5C','7CFC00','FA8072','2E8B57',
      '9ACD32','CCFFFF','99FFCC','FFFF33','99CC00',
      'FF99CC','CC99FF','9933CC','FF3366','990066',
      '66FF33','0099CC','669999','0033FF','003366',
      '666600','0000CC','FF3300','336699','006666',]
    sizes = ['10pt', '15pt', '17pt', '17pt', '18pt','22pt']
    ignore = [' ',"\n"]

    faggy_text = ''
    source_text.each_char do |char|
      unless ignore.include?(char)
        fg = colours[rand(colours.size)]
        bg = (fg.to_i(16) ^ 0xffffff).to_s(16).rjust(6,'0')
        styles = ["color: ##{fg}", "background-color: ##{bg}"]
        
        if rand(1) == 0
          size = sizes[rand(sizes.size)]
          styles << "font-size: #{size}"
        end

        if rand(3) == 0
          styles << 'text-decoration: blink'
        end

        if rand(5) == 0
          styles << 'font-weight: bold'
        end

        char = "<span style='#{styles.join(';')}'>#{char}</span>"
      end # unless

      faggy_text << char
    end # each_char

    return faggy_text
  end # fagify_text
end
