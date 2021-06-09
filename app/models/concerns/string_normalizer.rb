require "nkf"

module StringNormalizer
  extend ActiveSupport::Concern

  def normalize_as_email(text)
    NKF.nkf("-W -w -Z1", text).strip if text
  end

  def normalize_as_name(text)
    # -W 入力の文字コードをUTF-8と仮定する
    # -w UTF-8で出力する
    # -Z1 全角の英数字、記号、全角スペースを半角に変換する
    # stripは文字列の前後の空白を除去する
    NKF.nkf("-W -w -Z1", text).strip if text
  end

  def normalize_as_furigana(text)
    # --katakana ひらがなをカタカナに変換する
    NKF.nkf("-W -w -Z1 --katakana", text).strip if text
  end

  def normalize_as_postal_code(text)
    # 郵便番号に含まれる全角文字を半角に変換した後、ハイフン記号を除去
    NKF.nkf("-W -w -Z1", text).strip.gsub(/-/, "") if text
  end
  def normalize_as_phone_number(text)
    # normalize_as_name と同じ処理内容。用途が違うので別メソッドにしている
    NKF.nkf("-W -w -Z1", text).strip if text
  end
end