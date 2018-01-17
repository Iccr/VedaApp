module QR
  class Qr
    require 'fileutils'
    def generate_qr path
      puts 'qrqr'
      qr_storyboard_path = root + '/lib/QRCodeScanner/QRScanner.storyboard'
      qr_viewcontroller_path = root + '/lib/QRCodeScanner/QRCodeScannerViewController.swift'
      viewcontroller_extension_path = root + '/lib/QRCodeScanner/UIViewControllerExtension.swift'
      dest_folder = dest_folder_path path
      puts dest_folder

      FileUtils.cp(qr_storyboard_path, dest_folder)
      FileUtils.cp(qr_viewcontroller_path, dest_folder)
      FileUtils.cp(viewcontroller_extension_path, dest_folder)

      puts "successfully generated qr scanner in path: #{dest_folder}"
      viewcontroller_name = viewcontroller_name path

      puts viewcontroller_name

      f = File.open(path, 'a')
      f.write(extension viewcontroller_name)
      f.close
      fileContent = File.readlines(path)
      # puts fileContent
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
         func scan() {
            self.openQRCodeScanner(source: self) { (viewcontroller, string) in
                let qrString = string
                print(qrString)
            }
         }

         func openQRCodeScanner(source: UIViewController, completion: @escaping (QRCodeScannerViewController, String)->()) {
          if let vc = UIStoryboard(name: "QRScanner", bundle: nil).instantiateInitialViewController() as? QRCodeScannerViewController {
              vc.onObtained = completion
              source.present(vc, animated: true, completion: nil)
          }
      }
    }
      EOS
    end
  end
end
