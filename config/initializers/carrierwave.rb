CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/
CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    # 参考までにですが設定情報を管理するgemを使うと便利。rails_configやdotenv等
    # > 設定情報の管理にはfigaroを使っています。
    aws_access_key_id: ENV['aws_access'],
    aws_secret_access_key: ENV['aws_secret'],
    region: 'ap-northeast-1'
  }

  case Rails.env
    when 'production'
      config.fog_directory = 'dropbox-copy-app'
      config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/dropbox-copy-app'

    when 'development'
      config.fog_directory = 'dropbox-copy-app-dev'
      config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/dropbox-copy-app-dev'

    when 'test'
      config.fog_directory = 'dropbox-copy-app-test'
      config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/dropbox-copy-app-test'
  end
end
