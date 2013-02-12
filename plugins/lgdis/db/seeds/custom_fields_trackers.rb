# encoding: utf-8
# 削除（tracker_idが100以下 且つ custom_field_idが1000以下）
ActiveRecord::Base.connection.execute(%{DELETE FROM custom_fields_trackers WHERE tracker_id<= 100 and custom_field_id <= 1000})

# 登録
{  1 => [2,3,4,5,6,7,8,9,10,11,12,13],
  30 => [133,134,135,136,21],
   2 => [2,3,4,5,6,7,8,9,10,11,12,13],
  31 => [133],
   3 => [1,2,3,4,5,6,7,8,9,10,11,12,13,14,44],
   4 => [1,2,3,4,5,6,7,8,9,10,11,12,13,14,44],
   5 => [44],
   6 => [44],

   16 => [1,2,3,4,6,7,10,11,12,13,114,115,116,117,118,119,120,121],
   17 => [8,9,22,28,29,30,45,46,122,123,124,125,126,127,128,129,130,131],
   18 => [1,2,3,4,5,6,7,8,9,10,11,12,13,22,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113],

   7 => [28,29,30,137,142,143,144,145,147,148,149,150,151,152,153,154,155,156,189,420,421],
   8 => [28,29,30,31,32,33,137,157,189,420,421],
  33 => [28,29,30,33,34,35,137,157,189,420,421],
   9 => [28,29,30,137,159,160,161,162,163,164,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,189,200,420,421],
  10 => [28,29,30,137,159,160,164,168,170,171,172,174,175,176,178,179,180,181,182,183,184,185,189,200,419,420,421],
  11 => [28,29,30,137,188,189,191,192,193,194,195,196,200,201,202,209,420,421],
  12 => [28,29,30,137,188,189,200,203,204,205,206,207,208,209,210,211,420,421],
  13 => [28,29,30,137,188,189,209,200,212,213,214,215,216,217,218,219,420,421],
  14 => [28,29,30,137,188,189,200,209,220,221,222,223,224,225,226,227,420,421],
  34 => [28,29,30,137,189,280,283,284,285,286,287,288,289,290,291,292,293,294,295,296,311,420,421],
  35 => [28,29,30,137,189,280,283,284,285,286,287,288,289,290,291,292,293,294,295,296,311,420,421],
  36 => [28,29,30,137,189,280,283,284,285,286,287,288,289,290,291,292,293,294,295,296,311,420,421],
  37 => [28,29,30,137,189,280,283,284,285,286,287,288,289,290,291,292,293,294,295,296,311,420,421],
  38 => [28,29,30,137,189,280,283,284,285,286,287,288,289,290,291,292,293,294,295,296,311,420,421],
  39 => [28,29,30,137,189,280,289,290,291,292,293,294,295,296,310,311,313,314,315,316,317,420,421],
  40 => [28,29,30,137,189,280,289,290,291,292,293,294,295,296,311,322,323,324,327,328,329,330,331,332,333,334,335,336,337,338,339,340,420,421],
  41 => [28,29,30,137,189,280,294,295,296,289,290,291,292,293,311,420,421],
  15 => [28,29,30,33,137,140,141,189,420,421],

  22 => [28,29,30,137,159,160,161,162,189,252,253,254,255,256,257,258,420,421],
  23 => [28,29,30,137,159,160,161,162,189,259,260,420,421],
  24 => [28,29,30,137,159,160,161,162,189,261,262,263,420,421],
  26 => [28,29,30,137,159,160,161,162,189,272,273,274,420,421],
  67 => [28,29,30,137,189,420,421,423,424],
  68 => [3,28,29,30,137,189,420,421,422],
  69 => [3,28,29,30,137,189,420,421,422],
  70 => [3,28,29,30,137,189,420,421,422],
  28 => [28,29,30,38,39,41,137,189,420,421],
  71 => [28,29,30,38,40,42,43,137,189,420,421],
  29 => [28,29,30,38,40,42,43,137,189,420,421],
  48 => [28,29,30,137,189,420,421],

  20 => [2,4,8,9,10,11,12,13,14,28,29,30,159,160,161,162,165,189,230,231,232,233,234,236,237,238,239,240,241,242,243,244,245,420,421],
  21 => [2,4,8,9,10,11,12,13,14,28,29,30,159,160,161,162,189,236,237,238,247,248,249,250,251,420,421],
  25 => [2,4,8,9,10,11,12,13,14,28,29,30,159,160,161,162,189,236,237,238,264,265,266,267,268,269,271,420,421],
  27 => [2,4,8,9,10,11,12,13,14,28,29,30,159,160,161,162,189,275,276,277,278,420,421],
  42 => [2,4,8,9,10,11,12,13,14,28,29,30,162,188,189,343,344,345,346,420,421],
  72 => [2,4,8,9,10,11,12,13,14,28,29,30,162,188,189,343,344,345,346,420,421],
  73 => [2,4,8,9,10,11,12,13,14,28,29,30,162,188,189,343,344,345,346,420,421],
  74 => [2,4,8,9,10,11,12,13,14,28,29,30,162,188,189,343,344,345,346,420,421],
  75 => [2,4,8,9,10,11,12,13,14,28,29,30,162,188,189,343,344,345,346,420,421],
  55 => [2,4,8,9,10,11,12,13,14,28,29,30,188,189,420,421],
  50 => [2,4,8,9,10,11,12,13,14,28,29,30,188,189,420,421],

  43 => [2,4,8,9,10,11,12,13,14,28,29,30,188,189,191,192,193,194,195,196,200,201,202,209,420,421],
  44 => [2,4,8,9,10,11,12,13,14,28,29,30,188,189,203,204,205,206,207,208,200,209,210,211,420,421],
  45 => [2,4,8,9,10,11,12,13,14,28,29,30,188,189,200,209,212,213,214,215,216,217,218,219,420,421],
  46 => [2,4,8,9,10,11,12,13,14,28,29,30,188,189,200,209,220,221,222,223,224,225,226,227,420,421],
  51 => [2,4,8,9,10,11,12,13,14,28,29,30,188,189,420,421],

  52 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  62 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  63 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  60 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  61 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  66 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  59 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  56 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  54 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  57 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  58 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  64 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  65 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
  53 => [2,4,8,9,10,11,12,13,14,28,29,30,189,420,421],
    
  }.each {|tr_id, cf_ids|
  cf_ids.each {|cf_id|
    ActiveRecord::Base.connection.execute(%{INSERT INTO custom_fields_trackers (tracker_id, custom_field_id) VALUES (#{tr_id},#{cf_id})})
  }
}
