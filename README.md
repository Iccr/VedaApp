# Veda Ios modules generators
###### There are many times when we write same thing in different app. Like qr scanner, search etc. This is an attempt to automate the redundant task. Using command line we can generate specific task without writing all the codes. All codes generated can be customized according to your needs and are well tested. currently All codes are generated for Swift.


### QR scanner

**step 1:**

generate qr module with command line.

syntax:  `veda generate --qr path_to_viewcontroller`

example: 

`veda generate --qr /Users/shishirsapkota/Library/Autosave\ Information/qrTest/qrTest/ViewController.swift`

This will generate three files in the folder containing the viewcontroller.swift.  

**step 2:** 

Add files to your xcode project.

[Add files to your project like this](https://lh3.googleusercontent.com/yfMZKNaGzODzaQRtyGwUPJpRrhohbxheezgS04VRUeHvq3j9OgPrHnIDC_wNQTnSpv-S03OEPISFTEEVjl6WDmx3l-bMwmi0xNTYMgR-jgvHpy4sYRxBDUsl1SiNLPFJzDgz6ZUX9GaDQpwNLSqjXq5wFTE_O4TNgha_tHr1XI3eJu39wt5EX4HMWWKefzDKaOSac5OtEGUwZ_-LTju2J-3zMyD4q2tnbQ_uv853CCUWjqjcLOQ-6zsJYH9pJkf75yNsWV9We0-9kNKwCbPrEX6x-rdPux35dNTKmz5eC6czJo8ONgsmI2trfSxTN9ZCLIJ1YJP94RwdKlY-MtWpFdjZuqA3QGzB5rFIB98NkRqHx0hKk9UxP7QBYxeWl13O-Dd_RZJSNPn4gYXfav6SJbqvwd9HUv8uKCpCGAtn0QaK9YUZ6U9qHlBPTKfd74CmHB0aY-KQ4kc99a6h-SGMH72ARlkTe83__qgQyphwuPcU6rRn36ScNSxxwGkLZzzWwNkM8t7X1Fh7OGeN9WQ1E5oNxPzzwmJiP5S8e6ep6Rm2ISA7nb8qcHdyBLEj1QIcDAaIPYaxEuHfXVOMb2HtFXjrMVNP2BUVLzTPbWk=w340-h475-no)

Add three files generated.

[Files after added.](https://lh3.googleusercontent.com/2i-K6a8L-snz5FEWeua32K3bAezDJhsHvXlLXK3sDTZsrXNYOSi7WAO14txD4aPbjI8XHs75vg5y6TCt_E1DUafbMD9-wxMAp1pvcVXt_zDJSvSJkxZmd5m0Xa8Ht-hj7PENwViavB_7QLzrLlrQ9vE4rWcvRYMYiVxO3QkdqSle_0xlm_mUwyzivZzGIazj2GD6nM88kMEBn6fCoImIxeGF8Q1C4c_aZKi_7PsBDIaKN-NS5Uz_PoVZVudt5XPIP-vhzSOmx4shZ_OajX8nctjVwVbpJdSXMCig2MSX3EAuWZlzmYxbO0viM3qmU9U75kmzgKWVsceB3Izqbv0Xh7CyHhvaS1wtEKvT48LKRzImZgsRbUqTitFwIspdJ18rfuXIodZwmquXcRu3K_YxGGXiMozdW2MnE_K780-IW6BDO786TK2ACbVLQmZY0RBxj2-AsTfwW0mhIK9gn6OLBpltF924au8U_TaTbPRVXt_2PRFCH7CspogICbP3qO8_s8_6BnS1lGv5fx_RpqmarZta6D8bsH31YGdqFKf84qHhvhlrA4f5yhtJOhe9l6v2uv8LngCf6Hz_c-bWXfsve4wBphwCdYk_StILGJg=w262-h102-no)


**At the End of Your viewcontroller, extension where function to open the qr scanner is Automatically added.**

```swift
    extension ViewController {
         func scan() {
            self.openVedaQRScanner(source: self) { (viewcontroller, string) in
                let qrString = string
                print(qrString)
            }
         }

         func openVedaQRScanner(source: UIViewController, completion: @escaping (VedaQRScannerViewController, String)->()) {
          if let vc = UIStoryboard(name: "VedaQR", bundle: nil).instantiateInitialViewController() as? VedaQRScannerViewController {
              vc.onObtained = completion
              source.present(vc, animated: true, completion: nil)
          }
      }
    }
    
```

**step3**: 

create an outlet and open qrscanner

```swift
    @IBAction func openQr(_ sender: UIButton) {
        self.scan()
    }
```


Enjoy.
