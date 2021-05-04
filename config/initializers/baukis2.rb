Rails.application.configure do
  # configはRails gemの各種設定を保持している
  # このファイルでアプリ起動時に設定を自動で読み込むようにする
  # アクセス方法例：Rails.application.config.baukis2[:staff][:host]
  config.baukis2 = {
    staff: {host: "baukis2.example.com", path: ""},
    admin: {host: "baukis2.example.com", path: "admin"},
    customer: {host: "example.com", path: "mypage"},
  }
end
