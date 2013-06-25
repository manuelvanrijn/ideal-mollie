# Changelog

- **TBA**: version 1.0.4

- **25 June 2013**: version 1.0.3
    - Make Nokogiri version less restrictive by [@tijmenb](https://github.com/tijmenb)
    - Added different argument passing for `IdealMollie.new_order`

- **11 Februari 2012**: version 1.0.2
    - Fix for verify sha512

- **10 July 2012**: version 1.0.0
    - Released version 1.0
    - Added more platforms to test on Travis CI
    - Fixed spec for latest version of RSpec (2.11.0)

- **9 May 2012**: version 0.0.8
	- Upgraded dependency multi_xml to 0.5

- **26 April 2012**: version 0.0.7
    - Upgraded dependency faraday to 0.8
    - Upgraded dependency vcr to 2.1
    - Recorded the vcr cassettes to match the 2.1 format
	- Removed jruby dependency

- **30 January 2012**: version 0.0.6
    - Changed the URL to a CONST for testing on local sinatra server (coming soon)

- **30 January 2012**: version 0.0.5
    - Added support for multiple profile's

- **26 January 2012**: version 0.0.4
    - Changed property `payed` to `paid`

- **26 January 2012**: version 0.0.3
    - Added `Bank`, `Order` and `OrderResult`. Should be easier then hashes.
    - Added example to the README
    - Now you can override the return_url within the controller

- **25 January 2012**: version 0.0.2
    - Dependencies fixed
    - Tests fixed
    - Automation with Travis and Gemnasium

- **25 January 2012**: version 0.0.1
    - Initial release
