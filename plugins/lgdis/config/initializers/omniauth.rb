Rails.application.config.middleware.use OmniAuth::Builder do
  provider :open_id, :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
  provider :twitter, '6BD7k5IRNoKR9yzcYZBgQ', 'ndW0wTejpTs5fwqZX8GsDdLL1YfiUXL03jg8mdEA2Y'
  provider :facebook, '266345620165564', 'ba77e7cf1e5e080aa6bd394989e1bbf6'
end
# workaround for omniauth
OmniAuth.config.logger = Logger.new(STDOUT)
OmniAuth.logger.progname = "omniauth"
