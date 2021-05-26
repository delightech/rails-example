# libに汎用的なモジュールを配置している
module HtmlBuilder
  def markup(tag_name = nil, options = {})
    root = Nokogiri::HTML::DocumentFragment.parse("")
    Nokogiri::HTML::Builder.with(root) do |doc|
      if tag_name
        doc.method_missing(tag_name, options) do
          # メソッド実行時に渡されたブロックを実行
          yield(doc)
        end
      else
        # メソッド実行時に渡されたブロックを実行
        yield(doc)
      end
    end
    # HTMLに変換して返す
    root.to_html.html_safe
  end
end

# 例）<div class="notes"><span class="mark">*</span></div>を出力するmarkupメソッドの使い方1
# markup do |m|
#   m.div(class: "notes") do
#     m.span "*", class: "mark"
#   end
# end

# 例）<div class="notes"><span class="mark">*</span></div>を出力するmarkupメソッドの使い方2
# markup(:div, class: "notes") do |m|
#   m.span "*", class: "mark"
# end