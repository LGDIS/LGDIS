# encoding: utf-8
require 'rexml/document'
require 'xsd/datatypes'
require 'base64'
# NOTE: gem module 'soap4r' have to be greater/newer than ver.1.9.x,
#      otherwise causes 'Iconv deprecation' error in combination with ruby 1.9.3x or its newer ruby version.
require 'soap/rpc/driver'
require 'soap/wsdlDriver'
require 'savon'

module Lgdis
  module ExtOut
    class CommonsClient
      # soap element prefixes(namespaces)
      ENV_PREFIX = 'S'                # prefix for soap envelope
      PUB_INFO_COM_PREFIX = 'pcsoap'  # prefix for public information commons interface
      WS_SECURITY_PREFIX = 'wsse'      # prefix for ws-security
      WS_UTILITY_PREFIX = 'wsu'        # prefix for ws-utility
      XML_PREFIX = 'xml'              # prefix for xml

      # oasis wss URIs
      WSE_NAMESPACE_URI = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'        # Namespace for WS Security Secext.
      WSU_NAMESPACE_URI = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'      # Namespace for WS Security Utility.
      PASSWORD_TEXT_URI = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'    # PasswordText URI.
      PASSWORD_DIGEST_URI = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest'  # PasswordDigest URI.
      BASE64_URI = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary'

      # other URIs
      SOAP_ENVELOPE_URI = 'http://schemas.xmlsoap.org/soap/envelope/'
      PUB_INFO_COMMONS_URI = 'http://soap.publiccommons.ne.jp/'
      XML_NAMESPACE = 'http://www.w3.org/XML/1998/namespace'

      # 処理内容
      # ==== Args
      # _wdsl_ ::
      # _endpoint_ ::
      # _namespace_ ::
      # ==== Return
      # ==== Raise
      def initialize(wsdl, endpoint, namespace)
        @wsdl_uri = wsdl
        @endpoint_uri = endpoint
        @namespace_uri = namespace
      end

      # 処理内容
      # ==== Args
      # _username_ ::
      # __essword_ ::
      # ==== Return
      # ==== Raise
      def set_auth(username, password)
        @username = username
        @password = password
      end

      # SOAP形式メッセージを送信する
      # ==== Args
      # _data_ ::
      # ==== Return
      # ==== Raise
      def send(data)
        wsdl_uri = @wsdl_uri
        endpoint_uri = @endpoint_uri
        namespace_uri = @namespace_uri

        client = Savon.client do
          wsdl wsdl_uri
          endpoint endpoint_uri
          namespace namespace_uri
          #クライアントに配置した認証局証明書ファイルの場所
          #片側認証方式ではこれがあればよい
          unless (endpoint_uri =~ /https/).blank?
            if $0 == "script/rails"
              # Rails/Redmineから呼ばれた場合は設定ファイルの証明書を読む
              ssl_ca_cert_file DST_LIST['commons_connection']['ssl_ca_cert']
            else
              ssl_ca_cert_file "/opt/fix/SOAPdev/etc/pki/CA/cacert.pem"
            end
          end
          #以下2行はカギ情報伝送方式(例:X509認証)で必要になる
          #公開･プライベートカギ情報へのファイルパス
            #ssl_cert_file "
            #ssl_cert_key_file "
        end
        doc = create_soap_document(data)
        p doc
        response = client.call(:publish) do
          xml doc
        end
        return true
      end

    private
      # 処理内容
      # ==== Args
      # _data_ ::
      # ==== Return
      # ==== Raise
      def create_soap_document(data)
        doc = REXML::Document.new
        doc << REXML::XMLDecl.new

        # soap envelope
        #env_prefix = 'S'
        envelope = REXML::Element.new ENV_PREFIX + ':Envelope'
        envelope.add_namespace ENV_PREFIX, SOAP_ENVELOPE_URI

        soap_header = create_soap_header
        soap_body = create_soap_body(data)

        envelope.add soap_header
        envelope.add soap_body

        doc.add envelope
        return doc.to_s
      end

      # 処理内容
      # ==== Args
      # ==== Return
      # ==== Raise
      def create_wsse_header
        wsse_username = @username
        wsse_nonce = Base64.encode64((rand() * 1000000000).to_i.to_s).chomp
        wsse_created = XSD::XSDDateTime.new(Time.now.utc).to_s.slice(0,19) + 'Z'
        wssePassword = Base64.encode64(Digest::SHA1.digest(Base64.decode64(wsse_nonce) + wsse_created + @password)).chomp
        # security
        security_element = REXML::Element.new WS_SECURITY_PREFIX + ':Security'
    #     security_element.add_attribute ENV_PREFIX + ':mustUnderstand', '1'
        security_element.add_namespace WS_SECURITY_PREFIX, WSE_NAMESPACE_URI

        # usernameToken
        username_token_element = REXML::Element.new WS_SECURITY_PREFIX + ':UsernameToken'
        username_token_element.add_namespace WS_SECURITY_PREFIX, WSE_NAMESPACE_URI
        username_token_element.add_namespace WS_UTILITY_PREFIX, WSU_NAMESPACE_URI

        # username
        username_element = REXML::Element.new WS_SECURITY_PREFIX + ':Username'
        username_element.text = wsse_username
        username_token_element.add username_element

        # password
        password_element = REXML::Element.new WS_SECURITY_PREFIX + ':Password'
        password_element.add_attribute 'Type', PASSWORD_DIGEST_URI
        password_element.text = wssePassword
        username_token_element.add password_element

        # nonce
        nonce_element = REXML::Element.new WS_SECURITY_PREFIX + ':Nonce'
        nonce_element.add_attribute 'EncodingType', BASE64_URI
        nonce_element.text =wsse_nonce
        username_token_element.add nonce_element

        # created
        created_element = REXML::Element.new WS_UTILITY_PREFIX + ':Created'
        created_element.add_namespace WS_UTILITY_PREFIX, WSU_NAMESPACE_URI
        created_element.text = wsse_created
        username_token_element.add created_element

        security_element.add username_token_element
        return security_element
      end

      # 処理内容
      # ==== Args
      # ==== Return
      # ==== Raise
      def create_soap_header
        # soap header
        soap_header = REXML::Element.new ENV_PREFIX + ':Header'
        soap_header.add create_wsse_header
        return soap_header
      end

      # 処理内容
      # ==== Args
      # _data_ ::
      # ==== Return
      # ==== Raise
      def create_soap_body(data)
        # soap body
        soap_body = REXML::Element.new  ENV_PREFIX + ':Body'

        # These tags are specific to public information commons.
        publish_element = REXML::Element.new PUB_INFO_COM_PREFIX + ':publish'
        publish_element.add_namespace ENV_PREFIX, SOAP_ENVELOPE_URI
        publish_element.add_namespace PUB_INFO_COM_PREFIX, PUB_INFO_COMMONS_URI
        publish_element.add_namespace XML_PREFIX, XML_NAMESPACE
        message_element = REXML::Element.new PUB_INFO_COM_PREFIX + ':message'
        message_element.add data.root.deep_clone  # 子ノードも含めてコピーしないとdataを破壊的にaddされてしまうため(dataが空になる)

        publish_element.add message_element
        soap_body.add publish_element
        return soap_body
      end

    end
  end
end
