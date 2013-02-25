# -*- coding: utf-8 -*-
# suppress warning message of omniauth-openid
OpenID.fetcher.ca_file = '/etc/pki/tls/certs/ca-bundle.crt'
# external-authorize
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :open_id, :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
  provider :twitter, '6BD7k5IRNoKR9yzcYZBgQ', 'ndW0wTejpTs5fwqZX8GsDdLL1YfiUXL03jg8mdEA2Y'
  provider :facebook, '266345620165564', 'ba77e7cf1e5e080aa6bd394989e1bbf6'
  provider :saml,
  {
    :name                           => 'openam',
    :assertion_consumer_service_url => 'http://vmhost.example.com:3000/auth/openam/callback', # SP(RoR)へのリダイレクトURI
    :issuer                         => 'http://vmhost.example.com:3000/',
    :idp_sso_target_url             => 'http://app.isk.local:8080/openam/SSORedirect/metaAlias/idp', # IdPのSSO(SOAP)サービスURI
    #    :idp_cert                       => "-----BEGIN CERTIFICATE-----\n...-----END CERTIFICATE-----",
    :idp_cert_fingerprint           => "DE:F1:8D:BE:D5:47:CD:F3:D5:2B:62:7F:41:63:7C:44:30:45:FE:33",
    :name_identifier_format         => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
  }
end
