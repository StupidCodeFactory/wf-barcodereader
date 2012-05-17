# Wf::Barcodereader

This gem provide a way to scan QR barecode with apple isight or face time intergrated webcam  
This gem contains a binary of [imagesnap](http://iharder.sourceforge.net/current/macosx/imagesnap/), compiled on osx 10.7.4.
If you get into trouble with imagesnap, try to install it yourself, via [homebrew](https://github.com/mxcl/homebrew) or from source. 


## Installation

Install imagemagick:

	brew install imagemagick

Install  [zbar](http://zbar.sourceforge.net/)

	brew install zbar

Add this line to your application's Gemfile:

    gem 'wf-barcodereader', :git => 'https://github.com/StupidCodeFactory/wf-barcodereader'

And then execute:

    $ bundle


## Usage
In you shell type:

	$ barcode

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
