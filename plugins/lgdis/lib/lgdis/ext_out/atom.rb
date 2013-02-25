# encoding: utf-8
module Lgdis
  module ExtOut
    class Atom < Lgdis::ExtOut::Base
      # 項目定義
      attr_accessor(
          :output_dir,
          :output_file_name,
          :data
        )

      # Lgdis Atom I/F 出力処理
      # ==== Args
      # ==== Return
      # ==== Raise
      def output
        output_dir_path = Pathname(output_dir)
        FileUtils::mkdir_p(output_dir_path) unless File.exist?(output_dir_path) # 出力先ディレクトリを作成

        File.binwrite(output_dir_path.join(output_file_name.force_encoding("UTF-8")),
                      data.to_s) unless test_flag
      end

    end
  end
end
