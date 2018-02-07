module Web
  class WebView
    require 'fileutils'
    def generate_web_view path
      web_view_storyboard_path = root + '/lib/VedaWebView/Storyboard.storyboard'
      web_view_viewcontroller_path = root + '/lib/VedaWebView/WebLinksViewController.swift'

      dest_folder = dest_folder_path path
      copy web_view_storyboard_path, dest_folder
      copy web_view_viewcontroller_path, dest_folder
      viewcontroller_name = viewcontroller_name path
      write((extension viewcontroller_name), path)
      puts "successfully generated web_view scanner in path: #{dest_folder}"
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
\tfunc showWebView(url: String, title: String) {
\t\tlogger(url)
\t\tlet web = WebLinksViewController()
\t\tweb.url = url
\t\tweb.titleString = title
\t\tnavigationController?.pushViewController(web, animated: true)
\t}
}
EOS
    end
  end
end
