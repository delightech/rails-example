# あるオブジェクトに関連するHTMLコードを生成する役割を担うクラスをプレゼンター（デコレータ）と呼ぶ
# 本クラスはそれらのクラスの親クラス
# プレゼンターは非公式用語。Railsコミュニティから生まれた概念
# プレゼンターを実現するGemは存在する(ActiveDecoratorなど)が、ここでは自作している
# Viewからプレゼンター化することによるメリットとして、リファクタリングしやすくなることがあげられる。またコードを整理し、名前を付けて管理できるメリットもある。
# デメリットとしては、デザイナーが理解できない可能性がある。
class ModelPresenter
  include HtmlBuilder

  attr_reader :object, :view_context

  # 委譲（delegation）
  # ModelPresenterにrawメソッドとlink_toメソッドを持たせ、view_contextに委譲する
  # ModelPresenterのrawメソッド, link_toメソッドが呼ばれると、view_contextのrawメソッド, link_toメソッドが呼ばれるということ
  delegate :raw, :link_to, to: :view_context

  def initialize(object, view_context)
    @object = object
    @view_context = view_context
  end

  def created_at
    object.created_at.try(:strftime, '%Y/%m/%d %H:%M:%S')
  end

  def updated_at
    object.updated_at.try(:strftime, '%Y/%m/%d %H:%M:%S')
  end
end
