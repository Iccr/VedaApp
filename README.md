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

![alt text](https://lh3.googleusercontent.com/yfMZKNaGzODzaQRtyGwUPJpRrhohbxheezgS04VRUeHvq3j9OgPrHnIDC_wNQTnSpv-S03OEPISFTEEVjl6WDmx3l-bMwmi0xNTYMgR-jgvHpy4sYRxBDUsl1SiNLPFJzDgz6ZUX9GaDQpwNLSqjXq5wFTE_O4TNgha_tHr1XI3eJu39wt5EX4HMWWKefzDKaOSac5OtEGUwZ_-LTju2J-3zMyD4q2tnbQ_uv853CCUWjqjcLOQ-6zsJYH9pJkf75yNsWV9We0-9kNKwCbPrEX6x-rdPux35dNTKmz5eC6czJo8ONgsmI2trfSxTN9ZCLIJ1YJP94RwdKlY-MtWpFdjZuqA3QGzB5rFIB98NkRqHx0hKk9UxP7QBYxeWl13O-Dd_RZJSNPn4gYXfav6SJbqvwd9HUv8uKCpCGAtn0QaK9YUZ6U9qHlBPTKfd74CmHB0aY-KQ4kc99a6h-SGMH72ARlkTe83__qgQyphwuPcU6rRn36ScNSxxwGkLZzzWwNkM8t7X1Fh7OGeN9WQ1E5oNxPzzwmJiP5S8e6ep6Rm2ISA7nb8qcHdyBLEj1QIcDAaIPYaxEuHfXVOMb2HtFXjrMVNP2BUVLzTPbWk=w340-h475-no)

Add three files generated.

![alt text](https://lh3.googleusercontent.com/agRabsGqRD6tvA4ckMgOBwIF2AAaw7kfrV2nzv7EYwjXOuIvHdw0ZMYO3tVf1Ol2Y_dwvH9yKUAUZh3SaomDYXU4NhzLQnLu8VVpNtbV7efi-WPh4i-bG-msE4JPXU4DnvK-eKs20g_VuRuipM-XToabuCd40AqNAPqJkJmPZBIzeab___ZWJJ2V6mpj6f3LmtjERmmjZPLJ_hYRoVE_ig0U85HzktAnEQP-ruMKwvizBzUDqEL9zSohWL7ws9BiV91pN9qGKddgbwAbV-4a6nCpE7ZaDh3j8VI9SopbrwyDKBNp4_FP0YqCsH6EBYnSHcNFaajVDWn65_DHYwOkpzWPLCIeVs70k19iRhVl8fzjzKfz2BIEn0y2ZDKDkCZC8JjAUeC0l18jy71NfQb8g-pBso6DQzn1eGFRhIrUyEMlVG4V6TRYdx8Tc_K6wKpz-CEVeyXoTwzlylN8gr9BD6u0qICj0YQFH_wkMqIoJcxtmy2N9spt0K4zZojyeA0PwKQYrLqOsI5RGGncFCsOVAtDmq2KtNnTfhExfgceA770VzAG77cZ8HQVH_slQCa-GW4YKmpycEoNggmBr4Ms2mpiaNs0YFL7ni7AEzw=w262-h102-no)


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
