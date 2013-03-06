# encoding: utf-8
require 'jpmobile/datum_conv'

# チケット位置情報クラス
#
# 以下の位置座標の属性を持ちます。
# _point_   :: 経緯度
# _line_    :: 線
# _polygon_ :: 多角形
#
# それぞれ単一(文字列)、もしくは複数("()"もしくは"[]"で囲まれた、","区切の文字列)の"(y座標（経度）, x座標（緯度）)"を持ちます。
#   ig = IssueGeography.find(1)
#   p ig.point => "(141.311348,38.429947)"
#   p ig.line => "[(141.295813, 38.432199),(141.304995, 38.428642),(141.304661, 38.423173)]"
#   p ig.polygon => "((141.305297,38.437276),(141.306647,38.434827),(141.300402,38.432821))"
#   ig = IssueGeography.find(2)
#   p ig.line => "((141.295813, 38.432199),(141.304995, 38.428642),(141.304661, 38.423173))"
#
# 格納されている座標の測地系は、_datum_属性に格納されています。
#   ig = IssueGeography.find(3)
#   p ig1.datum => "世界測地系"
#   ig = IssueGeography.find(4)
#   p ig2.datum => "日本測地系"
class IssueGeography < ActiveRecord::Base
  unloadable

  belongs_to :issue, :dependent => :destroy

  attr_accessible :datum,:location,:point,:line,:polygon,:remarks

  # 世界測地系 => 日本における世界測地系（日本測地系2000） => "Japanese Geodetic Datum 2000"
  DATUM_JGD = "世界測地系"
  # 日本測地系 => 旧日本測地系 => "Tokyo Datum"
  DATUM_TKY = "日本測地系"
  
  # 測地系種別
  DATUM_OPTION = [DATUM_JGD, DATUM_TKY]

  validates :datum,
                :length => {:maximum => 10}
  validates :location,
                :length => {:maximum => 100}
  validates :remarks,
                :length => {:maximum => 255}

  # map表示向けの場所（locaton）ハッシュを返却します
  # ==== Args
  # ==== Return
  # map表示向けのハッシュ
  # * "location" :: 場所文字列
  # * "remarks" :: 備考
  # ==== Raise
  def location_for_map
    return nil if location.blank?
    return {"location" => location, "remarks" => remarks}
  end

  # map表示向けの経緯度（point）ハッシュを返却します
  # ==== Args
  # _to_datum_ :: 必要な測地系
  # ==== Return
  # map表示向けのハッシュ
  # * "points"  :: 座標
  # * "remarks" :: 備考
  # ==== Raise
  def point_for_map(to_datum)
    return nil if point.blank?
    points = self.class.yx_to_xy_with_conv_datum(point, datum, to_datum)
    return points_hash_for_map(points)
  end

  # map表示向けの線（line）ハッシュを返却します
  # ==== Args
  # _to_datum_ :: 必要な測地系
  # ==== Return
  # map表示向けのハッシュ
  # * "points"  :: 座標
  # * "remarks" :: 備考
  # ==== Raise
  def line_for_map(to_datum)
    return nil if line.blank?
    points = self.class.yx_to_xy_with_conv_datum(line, datum, to_datum)
    return points_hash_for_map(points)
  end

  # map表示向けの多角形（polygon）ハッシュを返却します
  # ==== Args
  # _to_datum_ :: 必要な測地系
  # ==== Return
  # map表示向けのハッシュ
  # * "points"  :: 座標
  # * "remarks" :: 備考
  # ==== Raise
  def polygon_for_map(to_datum)
    return nil if polygon.blank?
    points = self.class.yx_to_xy_with_conv_datum(polygon, datum, to_datum)
    return points_hash_for_map(points)
  end

  private

  # "(y座標（経度）, x座標（緯度）), (y,x),…"座標集合文字列を
  # [[x座標（緯度）, y座標（経度）],[x,y],…]座標配列に変換します。
  # 同時に、指定された測地系に変換します。
  # ==== Args
  # _yx_content_ :: yx座標集合文字列
  # _from_datum_ :: 変換元の測地系（不明な場合は、世界測地系とみなす）
  # _to_datum_ :: 変換先の測地系
  # ==== Return
  # xy座標配列（1座標の場合は[x,y]、複数座標の場合は[[x,y],[x,y],…]）
  # ==== Raise
  def self.yx_to_xy_with_conv_datum(yx_content, from_datum, to_datum)
    return nil if yx_content.blank?

    from_datum = DATUM_JGD unless DATUM_OPTION.include?(from_datum) # 不明な測地系の場合、初期値（世界測地系）と見なす

    raise "指定された測地系は許容できません。" unless (DATUM_OPTION.include?(from_datum) && DATUM_OPTION.include?(to_datum))

    yx_ary = yx_content.to_s.gsub(/[()\[\]]/,"").split(",").map(&:to_f)

    needs_conv_datum = (from_datum != to_datum)  # 測地系変換が必要かどうか

    xy_ary = []
    yx_ary.length.to_i.times do
      break if yx_ary.blank?
      y, x = yx_ary.shift(2)
      case to_datum
      when DATUM_JGD  # 日本測地系 => 世界測地系
        x, y = DatumConv.tky2jgd(x, y)
      when DATUM_TKY  # 世界測地系 => 日本測地系
        x, y = DatumConv.jgd2tky(x, y)
      end if needs_conv_datum
      xy_ary << [x, y]
    end

    return (xy_ary.length == 1 ? xy_ary.first : xy_ary)
  end

  # map表示向けの座標ハッシュを返却します
  # ==== Args
  # _points_ :: 座標配列
  # ==== Return
  # map表示向けのハッシュ
  # * "points"  :: 座標
  # * "remarks" :: 備考
  # ==== Raise
  def points_hash_for_map(points)
    return {"points" => points, "remarks" => remarks}
  end

end
