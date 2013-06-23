# -*- coding: utf-8 -*-
# suppress warning message of omniauth-openid
OpenID.fetcher.ca_file = '/etc/pki/tls/certs/ca-bundle.crt'
# external-authorize
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :open_id, :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
  provider :twitter, API_KEY['twitter']['consumer_key'], API_KEY['twitter']['consumer_secret']
  provider :facebook, API_KEY['facebook']['app_id'], API_KEY['facebook']['app_secret']
  provider :saml,
  {
    :name                           => 'openam',
    :assertion_consumer_service_url => API_KEY['openam']['assertion_consumer_service_url'], # SP(RoR)へのリダイレクトURI
    :issuer                         => API_KEY['openam']['issuer'],
    :idp_sso_target_url             => API_KEY['openam']['idp_sso_target_url'], # IdPのSSO(SOAP)サービスURI
#    :idp_cert                       => "-----BEGIN CERTIFICATE-----\n...-----END CERTIFICATE-----", # idp_cert_fingerprintと排他指定のため不要
    :idp_cert_fingerprint           => API_KEY['openam']['idp_cert_fingerprint'],
    :name_identifier_format         => API_KEY['openam']['name_identifier_format']
  }
end
