# config/initializers/sentry.rb
Sentry.init do |config|
    config.dsn = 'https://aaabfe945770fd82b242457fce344c6f@o4511382750232576.ingest.de.sentry.io/4511382763012176'
  
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.traces_sample_rate = 1.0
    config.environment = Rails.env
    config.release = 'v1.0'
    
    config.debug = true if Rails.env.development?
  end