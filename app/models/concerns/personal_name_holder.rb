module PersonalNameHolder
  extend ActiveSupport::Concern

  # 漢字、平仮名、カタカナ、長音符、アルファベットのみにマッチする
  HUMAN_NAME_REGEXP = /\A[\p{han}\p{hiragana}\p{katakana}\u{30fc}A-Za-z]+\z/

  # \p{katakana} は任意のカタカナ一文字にマッチする
  # \u{30fc} は長音符「-」1文字にマッチする
  KATAKANA_REGEXP = /\A[\p{katakana}\u{30fc}]+\z/

  included do
    include StringNormalizer

    before_validation do
      self.family_name = normalize_as_name(family_name)
      self.given_name = normalize_as_name(given_name)
      self.family_name_kana = normalize_as_furigana(family_name_kana)
      self.given_name_kana = normalize_as_furigana(given_name_kana)
    end

    # presence: trueで値が空の場合にバリデーションエラー（半角スペース、タブ文字も失敗する）
    validates :family_name, :given_name, presence: true, format: { with: HUMAN_NAME_REGEXP, allow_blank: true}
    # formatは正規表現にマッチするかのバリデーション。allow_blankオプションは、値が空の場合はバリデーションスキップ
    validates :family_name_kana, :given_name_kana, presence: true, format: { with: KATAKANA_REGEXP, allow_blank: true }
  end
end