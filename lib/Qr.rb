module QR
  class Qr
    require 'fileutils'
    def generate_qr path
      qr_storyboard_path = root + '/lib/VedaQRScanner/VedaQr.storyboard'
      qr_viewcontroller_path = root + '/lib/VedaQRScanner/VedaQRScannerViewController.swift'
      viewcontroller_extension_path = root + '/lib/VedaQRScanner/UIViewControllerExtension.swift'

      dest_folder = dest_folder_path path
      copy qr_storyboard_path, dest_folder
      copy qr_viewcontroller_path, dest_folder
      copy viewcontroller_extension_path, dest_folder
      viewcontroller_name = viewcontroller_name path
      write((extension viewcontroller_name), path)
      puts "successfully generated qr scanner in path: #{dest_folder}"
    end

    def write extension, path
      f = File.open(path, 'a')
      f.write(extension)
      f.close
    end

    def copy src_path, dest_path
      FileUtils.cp(src_path, dest_path)
    end

    def root
        File.expand_path '../..', __FILE__
    end

    def dest_folder_path path
      dest_folder = path.split('/').reverse.drop(1).reverse.join('/')
    end

    def viewcontroller_name path
      path.split('/').reverse.first.split('.').first
    end

    def extension name
      extension = <<-EOS
extension #{name} {
\tfunc scan() {
\t\tself.openVedaQRScanner(source: self) { (viewcontroller, string) in
\t\tlet qrString = string
\t\tprint(qrString)
\t\t}
\t}

\tfunc openVedaQRScanner(source: UIViewController, completion: @escaping (VedaQRScannerViewController, String)->()) {
\t\tif let vc = UIStoryboard(name: "VedaQR", bundle: nil).instantiateInitialViewController() as? VedaQRScannerViewController {
\t\t\tvc.onObtained = completion
\t\t\tsource.present(vc, animated: true, completion: nil)
\t\t}
\t}
}
EOS
    end
  end
end
