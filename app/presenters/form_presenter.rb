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
      object.errors.full_messages_for(name).each do |message|
        m.div(class: "error-message") do |m|
          m.text message
        end
      end
    end
  end

  private def decorated_label(name, label_text, options = {})
    label(name, label_text, class: options[:required] ? "required" : nil)
  end
end