# -*- coding: utf-8 -*-

# ZNET TOWN #2.0 におけるサーバサイドAPI 認証機能
class ZNETTOWNService

  class LoginError < StandardError; end
  class HTTPFailed < StandardError; end
  class XMLParseFailed < StandardError; end

  # 定数
  # ZNET TOWNからのステータスコードの内容
  STATUS = {
    "10100000" => "正常終了（＝認証OK）",
    "10300000" => "正常終了（＝パラメータで送信された認証承認ID が有効）",
    "10112001" => "ユーザID が見つからない",
    "10112002" => "パスワードが不一致",
    "10112003" => "端末ID エラー",
    "10112004" => "サービス端末コードエラー",
    "10112005" => "ライセンスオーバー（UID の同時ログイン数）",
    "10112006" => "ライセンスオーバー（CID の同時ログイン数）",
    "10112007" => "ライセンスオーバー（ログイン回数）",
    "10112008" => "サービス利用不可（サービス期間外）",
    "10112009" => "サービス利用不可（サービス時間外）",
    "10112010" => "CID が不一致",
    "10112011" => "SID が不一致",
    "10112012" => "ac の値が不正",
    "10112900" => "認証サーバ接続エラー",
    "10112999" => "認証サーバエラー（その他）",
    "10113999" => "その他エラー（クッキー設定の失敗）",
    "10119001" => "入力パラメータエラー（null）",
    "10119002" => "入力パラメータエラー(フォーマットエラー)",
    "10119999" => "入力パラメータエラー（その他）",
  }
  # 正常(Cookie発行が必要)とみなすステータスコード
  SUCCESS_BEGIN_STATUS = "10100000"
  # 正常(Cookie発行が不要)とみなすステータスコード
  SUCCESS_CONTINUE_STATUS = "10300000"
  # COOKIE名称として許容する項目
  COOKIE_NAMES = [:ZNT_AID, :ZNT_CID, :ZNT_UID, :ZNT_SID, :ZNT_USERNM, :ZNT_INIT_MAP_KIND, :ZNT_INIT_MAP_SCALE, :ZNT_INIT_X, :ZNT_INIT_Y, :ZNT_SSL, :ZNT_LAST_LOGIN_DT, :ZNT_LAST_LOGIN_RS]

  @@authorized_aid = nil
  @@authorized_cookies = nil

  # ZNETTOWN機能の有効状態を取得する
  # ==== Args
  # ==== Return
  # 有効の有無(true/fales)
  # ==== Raise
  def self.enable?
    !!ZNETTOWN["enable"] rescue false
  end

  # ZNETTOWN CGIサーバにlogin要求を行う
  # 正常時はAID(認証承認ID)やCookie生成情報を返却する
  # ただし既存のAIDが有効の場合は生成済のCookie情報を返却する
  # 既存のAIDが無効の場合は、ZNETTOWN CGIサーバにlogin要求をしてookie生成情報を返却する
  # ==== Args
  # ==== Return
  # ZNETTOWN CGIレスポンス(Hash)
  # ==== Raise
  # LoginError :: AIDが取得できなかった場合に発生
  def self.login
    raise LoginError.new unless self.enable?
    begin
      uri_host  = ZNETTOWN["uri_host"]
      uri_local = ZNETTOWN["uri_local"]
      uid       = ZNETTOWN["uid"]
      pwd       = ZNETTOWN["pwd"]
      cid       = ZNETTOWN["cid"]

      send_http_request(uri_host, uri_local, cid, uid, pwd) do |response|
        result = parse_xml(response)
        Rails.logger.info "ZNET TOWN API: #{STATUS[result[:status]]}(#{result[:status]})"
        Rails.logger.debug "parsed_result:" + result.inspect

        case result[:status]
        when SUCCESS_BEGIN_STATUS
          @@authorized_aid = result[:aid]
          @@authorized_cookies = result
          return @@authorized_cookies
        when SUCCESS_CONTINUE_STATUS
          return @@authorized_cookies
        end
      end
    rescue HTTPFailed, XMLParseFailed => e
      Rails.logger.error "#{e.class}: #{e.message}"
    rescue
      @@authorized_aid = nil
      @@authorized_cookies = nil
      raise
    end
    raise LoginError.new
  end

  private

  # ZNET TOWN側CGIと通信して結果を取得する
  # 通信レスポンス文字列(String)を引数としたブロックを生成する
  # ==== Args
  # _uri_host_ :: CGIのホスト名部分(String) ex)"http:www.example.com"
  # _uri_local_ :: CGIのローカル部分(String) ex)"/cgi-bin/auth.cgi"
  # _cid_ :: 事前に通知されているCID(企業コード)(String)
  # _uid_ :: ユーザを識別するID(String)
  # _pwd_ :: ユーザに紐付くパスワード(String)
  # ==== Return
  # ==== Raise
  # HTTPFailed :: HTTP通信エラー時に発生
  def self.send_http_request(uri_host, uri_local, cid, uid, pwd)
    begin
      conn = Faraday.new(:url => uri_host) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      # HTTP Request(GET)
      request_param = {
        :UID => uid,
        :PWD => pwd,
        :CID => cid,
      }

      request_param[:AID] = @@authorized_aid if @@authorized_aid
      response = conn.get uri_local, request_param
      if response.status == 200
        yield response.body
      else
        raise HTTPFailed.new("response code=#{response.status}")
      end
    rescue => e
      raise HTTPFailed.new(e.message)
    end
  end

  # XMLをパースし必要な値を取得する
  # ==== Args
  # _xml_string_ :: XML文字列(String)
  # ==== Return
  # パース結果(Hash)
  # ==== Raise
  # XMLParseFailed :: XMLが所定の書式でなくパースできなかった場合に発生
  def self.parse_xml(xml_string)
    begin
      xml = Nokogiri::XML(xml_string)
      result = {
        :status  => xml.xpath("//result/status").text,
        :aid     => xml.xpath("//result/aid").text,
        :cookies => {
          :expires => xml.xpath("//result/cookies").attribute("expires").text,
          :path    => xml.xpath("//result/cookies").attribute("path").text,
          :cookie  => {},
        },
      }
      xml.xpath("//result/cookies").children.each do |cookie|
        key = cookie.attribute("name").text.to_sym
        if COOKIE_NAMES.include?(key)
          result[:cookies][:cookie][cookie.attribute("name").text.to_sym] = cookie.children.text
        end
      end
    rescue => e
      Rails.logger.debug xml_string
      raise XMLParseFailed.new("invalid response.")
    end
    return result
  end
end
