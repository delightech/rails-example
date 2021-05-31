class FormPresenter
  include HtmlBuilder

  attr_reader :form_builder, :view_context
  # Viewのform_withのブロック引数fがform_builderとして渡されてくる
  # labelなどのform_builderのメソッドをFormPresenterに持たせて、実行をform_builderに委譲している
  # FormPresenter#labelを実行すると、form_builder#labelが実行されるということ
  delegate :label, :text_field, :date_field, :password_field,
    :check_box, :radio_button, :text_area, :object, to: :form_builder

  def initialize(form_builder, view_context)
    @form_builder = form_builder
    @view_context= view_context
  end

  def notes
    markup(:div, class: "notes") do |m|
      m.span "*", class: "mark"
      m.text "印の付いた項目は入力必須です。"
    end
  end

  def text_field_block(name, label_text, options = {})
    markup(:div, class: "input-block") do |m|
      m << decorated_label(name, label_text, options)
      m << text_field(name, options)
      m << error_messages_for(name)
    end
  end

  def password_field_block(name, label_text, options = {})
    markup(:div, class: "input-block") do |m|
      m << decorated_label(name, label_text, options)
      m << password_field(name, options)
      m << error_messages_for(name)
    end
  end

  def date_field_block(name, label_text, options = {})
    markup(:div, class: "input-block") do |m|
      m << decorated_label(name, label_text, options)
      m << date_field(name, options)
      m << error_messages_for(name)
    end
  end

  def error_messages_for(name)
    markup do |m|
      # ActiveRcordのErrorsオブジェクトの full_message_for メソッドは、引数に指定された属性に関するエラーメッセージの配列を返す
      # 引数に :email を指定すれば、object の :email 属性に関するエラーメッセージのリストが返る

      # i18nのロードパスは以下で確認できる
      # bin/rails r 'pp I18n.load_path'
      object.errors.full_messages_for(name).each do |message|
        m.div(class: "error-message") do |div|
          div.text message
        end
      end
    end
  end

  def drop_down_list_block(name, label_text, choices, options = {})
    markup(:div, class: "input-block") do |m|
      m << decorated_label(name, label_text, options)
      # selectメソッドはセレクトボックスを追加する
      # 第二引数に選択項目の配列、第三引数にselectメソッドの振る舞い指定、第四引数にはHTMLのselect要素の属性オプション
      # 第三引数でinclude_blankオプションをtrueにすると、空白の選択肢がリストの先頭に追加される
      m << form_builder.select(name, choices, {include_blank: true}, options)
      m << error_messages_for(name)
    end
  end

  private def decorated_label(name, label_text, options = {})
    label(name, label_text, class: options[:required] ? "required" : nil)
  end
end